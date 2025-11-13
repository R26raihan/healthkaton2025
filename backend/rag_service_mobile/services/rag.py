"""
RAG Service Mobile - User-friendly Medical Records Q&A with friendly, engaging responses
"""
from typing import List, Dict, Optional
from sqlalchemy.orm import Session
from sqlalchemy import text
from datetime import datetime
import re

from ..core.config import (
    LLM_PROVIDER,
    LLM_MODEL_NAME,
    LLM_API_KEY,
    MAX_CONTEXT_DOCUMENTS,
    SIMILARITY_THRESHOLD,
    MAX_RESPONSE_TOKENS,
    TEMPERATURE
)
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from pydantic import BaseModel

class DocumentChunk(BaseModel):
    doc_id: str
    patient_id: int
    record_id: Optional[str]
    chunk_text: str
    similarity_score: float
    metadata: Optional[dict] = None

def search_documents(
    query: str,
    patient_id: Optional[int] = None,
    limit: int = 10,
    threshold: float = 0.6,
    db: Session = None
) -> List[DocumentChunk]:
    """Search medical documents by semantic similarity"""
    if patient_id:
        query_sql = text("""
            SELECT doc_id, patient_id, record_id, extract_text, file_url, created_at
            FROM medical_documents
            WHERE patient_id = :patient_id
            AND extract_text IS NOT NULL
            AND extract_text != ''
            ORDER BY created_at DESC
            LIMIT :limit
        """)
        result = db.execute(query_sql, {"patient_id": patient_id, "limit": limit * 2})
    else:
        query_sql = text("""
            SELECT doc_id, patient_id, record_id, extract_text, file_url, created_at
            FROM medical_documents
            WHERE extract_text IS NOT NULL
            AND extract_text != ''
            ORDER BY created_at DESC
            LIMIT :limit
        """)
        result = db.execute(query_sql, {"limit": limit * 2})
    
    query_lower = query.lower()
    query_words = set(query_lower.split())
    stop_words = {'yang', 'dan', 'atau', 'dari', 'di', 'ke', 'pada', 'untuk', 'dengan', 'bagaimana', 'apa', 'apakah', 'saya', 'saya', 'saya'}
    query_words = {w for w in query_words if w not in stop_words and len(w) > 2}
    
    documents = []
    
    for row in result:
        if not row.extract_text:
            continue
        
        text_lower = row.extract_text.lower()
        text_words = set(text_lower.split())
        
        if not query_words:
            continue
        
        matches = len(query_words.intersection(text_words))
        similarity = matches / len(query_words) if query_words else 0
        
        effective_threshold = threshold if matches > 0 else threshold * 0.3
        
        if similarity >= effective_threshold:
            full_text = row.extract_text
            chunk_text = full_text[:3000] if len(full_text) > 3000 else full_text
            
            chunk = DocumentChunk(
                doc_id=row.doc_id,
                patient_id=row.patient_id,
                record_id=row.record_id,
                chunk_text=chunk_text,
                similarity_score=similarity,
                metadata={
                    "file_url": row.file_url,
                    "created_at": str(row.created_at),
                    "source": "medical_document"
                }
            )
            documents.append(chunk)
    
    documents.sort(key=lambda x: x.similarity_score, reverse=True)
    return documents[:limit]

def search_medical_records(
    query: str,
    patient_id: int,
    limit: int = 5,
    db: Session = None
) -> List[DocumentChunk]:
    """Search medical records (diagnoses, prescriptions, notes, lab results) for context"""
    query_lower = query.lower()
    query_words = set(query_lower.split())
    stop_words = {'yang', 'dan', 'atau', 'dari', 'di', 'ke', 'pada', 'untuk', 'dengan', 'bagaimana', 'apa', 'apakah', 'saya', 'ini', 'itu'}
    query_words = {w for w in query_words if w not in stop_words and len(w) > 2}
    
    query_sql = text("""
        SELECT 
            mr.record_id,
            mr.patient_id,
            mr.diagnosis_summary,
            mr.notes,
            mr.visit_date,
            mr.visit_type,
            mr.doctor_name,
            mr.facility_name,
            GROUP_CONCAT(DISTINCT d.diagnosis_name SEPARATOR ', ') as diagnoses,
            GROUP_CONCAT(DISTINCT d.icd_code SEPARATOR ', ') as icd_codes,
            GROUP_CONCAT(DISTINCT CONCAT(p.drug_name, ' (', COALESCE(p.dosage, ''), ', ', COALESCE(p.frequency, ''), ')') SEPARATOR '; ') as prescriptions,
            GROUP_CONCAT(DISTINCT CONCAT(lr.test_name, ': ', lr.result_value, ' ', COALESCE(lr.result_unit, ''), 
                         CASE WHEN lr.normal_range IS NOT NULL THEN CONCAT(' [Normal: ', lr.normal_range, ']') ELSE '' END) 
                         SEPARATOR '; ') as lab_results
        FROM medical_records mr
        LEFT JOIN diagnoses d ON mr.record_id = d.record_id
        LEFT JOIN prescriptions p ON mr.record_id = p.record_id
        LEFT JOIN lab_results lr ON mr.record_id = lr.record_id
        WHERE mr.patient_id = :patient_id
        GROUP BY mr.record_id, mr.patient_id, mr.diagnosis_summary, mr.notes, 
                 mr.visit_date, mr.visit_type, mr.doctor_name, mr.facility_name
        ORDER BY mr.visit_date DESC
        LIMIT :limit
    """)
    
    result = db.execute(query_sql, {"patient_id": patient_id, "limit": limit * 3})
    chunks = []
    
    for row in result:
        visit_date_str = row.visit_date.strftime("%d %B %Y") if row.visit_date else "Tanggal tidak diketahui"
        visit_type_str = row.visit_type or "kunjungan"
        doctor_str = f"Dokter: {row.doctor_name}" if row.doctor_name else ""
        facility_str = f"Fasilitas: {row.facility_name}" if row.facility_name else ""
        
        text_parts = []
        text_parts.append(f"=== Rekam Medis - {visit_date_str} ({visit_type_str}) ===")
        if doctor_str:
            text_parts.append(doctor_str)
        if facility_str:
            text_parts.append(facility_str)
        
        if row.diagnoses:
            icd_part = f" (ICD: {row.icd_codes})" if row.icd_codes else ""
            text_parts.append(f"Diagnosis: {row.diagnoses}{icd_part}")
        
        if row.diagnosis_summary:
            text_parts.append(f"Ringkasan: {row.diagnosis_summary}")
        
        if row.notes:
            text_parts.append(f"Catatan: {row.notes}")
        
        if row.prescriptions:
            text_parts.append(f"Resep Obat: {row.prescriptions}")
        
        if row.lab_results:
            text_parts.append(f"Hasil Lab: {row.lab_results}")
        
        combined_text = "\n".join(text_parts)
        combined_text_lower = combined_text.lower()
        text_words = set(combined_text_lower.split())
        
        if query_words:
            matches = len(query_words.intersection(text_words))
            similarity = matches / len(query_words) if query_words else 0.5
            
            medical_keywords = ['diagnosis', 'diagnosa', 'obat', 'resep', 'lab', 'alergi', 'allergy', 
                              'diabetes', 'hipertensi', 'tekanan', 'darah', 'gula', 'kolesterol']
            query_medical_match = any(kw in query_lower for kw in medical_keywords)
            text_medical_match = any(kw in combined_text_lower for kw in medical_keywords)
            if query_medical_match and text_medical_match:
                similarity = min(1.0, similarity + 0.2)
        else:
            similarity = 0.3
        
        if len(combined_text) > 3000:
            important_parts = []
            if row.diagnoses:
                important_parts.append(f"Diagnosis: {row.diagnoses}")
            if row.diagnosis_summary:
                important_parts.append(f"Ringkasan: {row.diagnosis_summary[:500]}")
            if row.prescriptions:
                important_parts.append(f"Resep: {row.prescriptions}")
            combined_text = "\n".join(important_parts)
        
        chunk = DocumentChunk(
            doc_id=f"record_{row.record_id}",
            patient_id=row.patient_id,
            record_id=row.record_id,
            chunk_text=combined_text,
            similarity_score=similarity,
            metadata={
                "visit_date": str(row.visit_date),
                "visit_type": row.visit_type,
                "doctor_name": row.doctor_name,
                "facility_name": row.facility_name,
                "source": "medical_record"
            }
        )
        chunks.append(chunk)
    
    chunks.sort(key=lambda x: x.similarity_score, reverse=True)
    return chunks[:limit]

def get_patient_allergies_context(patient_id: int, db: Session) -> Optional[str]:
    """Get patient allergies as context string"""
    query_sql = text("""
        SELECT allergy_name, severity, notes
        FROM allergies
        WHERE patient_id = :patient_id
        ORDER BY created_at DESC
    """)
    
    result = db.execute(query_sql, {"patient_id": patient_id})
    allergies = []
    
    for row in result:
        severity_str = row.severity or "moderate"
        notes_str = f" ({row.notes})" if row.notes else ""
        allergies.append(f"- {row.allergy_name} (Tingkat: {severity_str}){notes_str}")
    
    if allergies:
        return "=== Riwayat Alergi ===\n" + "\n".join(allergies)
    return None

def get_health_calculations_context(user_id: int, db: Session, limit: int = 10) -> Optional[str]:
    """Get user's health calculations as context string"""
    try:
        query_sql = text("""
            SELECT calculation_type, result_data, calculated_at
            FROM health_calculations
            WHERE user_id = :user_id
            ORDER BY calculated_at DESC
            LIMIT :limit
        """)
        
        result = db.execute(query_sql, {"user_id": user_id, "limit": limit})
        calculations = []
        
        for row in result:
            calc_type = row.calculation_type
            # Handle JSON column - MySQL returns JSON as string or dict depending on version
            result_data_raw = row.result_data
            if isinstance(result_data_raw, str):
                try:
                    import json
                    result_data = json.loads(result_data_raw)
                except:
                    result_data = {}
            elif isinstance(result_data_raw, dict):
                result_data = result_data_raw
            else:
                result_data = {}
            
            calculated_at = row.calculated_at.strftime("%d %B %Y") if row.calculated_at else "Tanggal tidak diketahui"
            
            # Format calculation result based on type
            calc_info = f"\n[{calculated_at}] {calc_type}: "
            
            if calc_type == "BMI":
                bmi = result_data.get("bmi", "N/A")
                category = result_data.get("category", "N/A")
                calc_info += f"BMI {bmi} ({category})"
            elif calc_type == "BMR":
                bmr = result_data.get("bmr", "N/A")
                calc_info += f"BMR {bmr} kcal/hari"
            elif calc_type == "TDEE":
                tdee = result_data.get("tdee", "N/A")
                activity = result_data.get("activity_level", "N/A")
                calc_info += f"TDEE {tdee} kcal/hari (Aktivitas: {activity})"
            elif calc_type == "BodyFat":
                body_fat = result_data.get("body_fat_percentage", "N/A")
                category = result_data.get("category", "N/A")
                calc_info += f"Body Fat {body_fat}% ({category})"
            elif calc_type == "MaxHeartRate":
                mhr = result_data.get("max_heart_rate", "N/A")
                calc_info += f"Max Heart Rate {mhr} bpm"
            elif calc_type == "MAP":
                map_value = result_data.get("mean_arterial_pressure", "N/A")
                category = result_data.get("category", "N/A")
                calc_info += f"MAP {map_value} mmHg ({category})"
            elif calc_type == "DailyCalories":
                calories = result_data.get("daily_calories", "N/A")
                goal = result_data.get("goal", "N/A")
                calc_info += f"Kebutuhan Kalori {calories} kcal/hari (Tujuan: {goal})"
            elif calc_type == "Macronutrients":
                protein = result_data.get("protein", {}).get("grams", "N/A")
                carbs = result_data.get("carbohydrates", {}).get("grams", "N/A")
                fat = result_data.get("fat", {}).get("grams", "N/A")
                calc_info += f"Protein: {protein}g, Karbohidrat: {carbs}g, Lemak: {fat}g"
            elif calc_type == "VO2Max":
                vo2_max = result_data.get("vo2_max", "N/A")
                category = result_data.get("category", "N/A")
                calc_info += f"VO₂ Max {vo2_max} ml/kg/min ({category})"
            elif calc_type == "WaterNeeds":
                water = result_data.get("daily_water_needs", "N/A")
                calc_info += f"Kebutuhan Air {water} liter/hari"
            elif calc_type == "BodyWater":
                water_pct = result_data.get("body_water_percentage", "N/A")
                calc_info += f"Body Water {water_pct}%"
            elif calc_type == "IdealBodyWeight":
                ibw = result_data.get("ideal_body_weight", "N/A")
                calc_info += f"Berat Badan Ideal {ibw} kg"
            elif calc_type == "BodySurfaceArea":
                bsa = result_data.get("body_surface_area", "N/A")
                calc_info += f"Body Surface Area {bsa} m²"
            else:
                # Generic format for other calculation types
                calc_info += str(result_data)
            
            calculations.append(calc_info)
        
        if calculations:
            return "=== Data Perhitungan Kesehatan ===\n" + "\n".join(calculations)
        return None
    except Exception as e:
        print(f"Error retrieving health calculations: {str(e)}")
        return None

def get_health_metrics_context(user_id: int, db: Session, limit: int = 20) -> Optional[str]:
    """Get user's health metrics history as context string"""
    try:
        query_sql = text("""
            SELECT metric_type, metric_value, unit, recorded_at
            FROM health_metrics_history
            WHERE user_id = :user_id
            ORDER BY recorded_at DESC
            LIMIT :limit
        """)
        
        result = db.execute(query_sql, {"user_id": user_id, "limit": limit})
        metrics_by_type = {}
        
        for row in result:
            metric_type = row.metric_type
            metric_value = float(row.metric_value) if row.metric_value else 0
            unit = row.unit or ""
            recorded_at = row.recorded_at.strftime("%d %B %Y") if row.recorded_at else "Tanggal tidak diketahui"
            
            if metric_type not in metrics_by_type:
                metrics_by_type[metric_type] = []
            
            metrics_by_type[metric_type].append({
                "value": metric_value,
                "unit": unit,
                "date": recorded_at
            })
        
        if not metrics_by_type:
            return None
        
        # Format metrics by type
        metrics_text = []
        for metric_type, values in metrics_by_type.items():
            latest = values[0]  # Most recent
            metric_info = f"{metric_type}: {latest['value']} {latest['unit']} (Terakhir: {latest['date']})"
            
            # Add trend if multiple values
            if len(values) > 1:
                previous = values[1]
                if latest['value'] > previous['value']:
                    trend = "↑ Naik"
                elif latest['value'] < previous['value']:
                    trend = "↓ Turun"
                else:
                    trend = "→ Stabil"
                metric_info += f" [{trend}]"
            
            metrics_text.append(metric_info)
        
        if metrics_text:
            return "=== Riwayat Metrik Kesehatan ===\n" + "\n".join(metrics_text)
        return None
    except Exception as e:
        print(f"Error retrieving health metrics: {str(e)}")
        return None

def remove_markdown_formatting(text: str) -> str:
    """
    Remove markdown formatting and special characters from text to return plain text
    Optimized for TTS (Text-to-Speech) - removes characters that TTS would read aloud
    Removes: **bold**, *italic*, # headers, ```code blocks```, [links](url), /, (), etc.
    """
    if not text:
        return text
    
    # Remove bold/italic: **text** or *text* or __text__ or _text_
    text = re.sub(r'\*\*(.*?)\*\*', r'\1', text)
    text = re.sub(r'\*(.*?)\*', r'\1', text)
    text = re.sub(r'__(.*?)__', r'\1', text)
    text = re.sub(r'_(.*?)_', r'\1', text)
    
    # Remove headers: # Header, ## Header, ### Header, etc.
    text = re.sub(r'^#{1,6}\s+(.+)$', r'\1', text, flags=re.MULTILINE)
    
    # Remove code blocks: ```code``` or `code`
    text = re.sub(r'```[\s\S]*?```', '', text)
    text = re.sub(r'`([^`]+)`', r'\1', text)
    
    # Remove links: [text](url) -> text
    text = re.sub(r'\[([^\]]+)\]\([^\)]+\)', r'\1', text)
    
    # Remove strikethrough: ~~text~~
    text = re.sub(r'~~(.*?)~~', r'\1', text)
    
    # Remove horizontal rules: --- or ***
    text = re.sub(r'^[-*]{3,}$', '', text, flags=re.MULTILINE)
    
    # Remove special formatting characters that TTS would read aloud
    # Remove forward slashes (/) - replace with space for better TTS pronunciation
    # Handle patterns like "3x/hari" -> "3x hari" or "dan/lain" -> "dan lain"
    text = re.sub(r'(\w+)/(\w+)', r'\1 \2', text)  # word/word -> word word
    text = re.sub(r'(\d+)/(\d+)', r'\1 per \2', text)  # 3/4 -> 3 per 4 (for fractions/dosage)
    text = re.sub(r'/(\w+)', r' \1', text)  # /word ->  word (standalone, add space)
    text = re.sub(r'(\w+)/', r'\1 ', text)  # word/ -> word  (standalone, add space)
    text = re.sub(r'\s+/', ' ', text)  # Remove standalone slashes with space before
    text = re.sub(r'/\s+', ' ', text)  # Remove standalone slashes with space after
    text = re.sub(r'/', ' ', text)  # Remove any remaining slashes (replace with space)
    
    # Remove formatting brackets like [text] but keep the content inside
    # This removes brackets but keeps medical information
    text = re.sub(r'\[([^\]]+)\]', r'\1', text)  # [text] -> text
    
    # Remove empty parentheses
    text = re.sub(r'\(\s*\)', '', text)
    
    # Remove special formatting symbols that TTS might pronounce weirdly
    # Keep friendly emojis (😊, 💊, 🏥, 💉, etc.) but remove formatting symbols
    text = re.sub(r'✅|❌|⚠️|➡️|⬅️|⬆️|⬇️|💡|🔍|📌|📍|➤|►|◄|▪|▫|•', '', text)
    # Note: Regular emojis like 😊, 💊, 🏥, 💉, 🙏, 💪 are kept for friendly tone
    
    # Remove multiple consecutive slashes or special chars
    text = re.sub(r'/{2,}', '', text)  # Remove multiple slashes
    text = re.sub(r'[-*]{2,}', '', text)  # Remove multiple dashes/asterisks
    
    # Replace newlines for TTS-friendly output
    # Replace double newlines (paragraph breaks) with period and space for natural pause
    text = re.sub(r'\n\n+', '. ', text)
    # Replace single newlines with space
    text = re.sub(r'\n', ' ', text)
    
    # Clean up extra spaces (but preserve single spaces)
    text = re.sub(r' +', ' ', text)
    
    # Clean up multiple periods (more than 3 consecutive)
    text = re.sub(r'\.{4,}', '...', text)
    
    # Clean up spaces around periods
    text = re.sub(r'\. +\.', '.', text)  # Remove space between periods
    text = re.sub(r' +\.', '.', text)  # Remove space before period
    text = re.sub(r'\. +', '. ', text)  # Ensure single space after period
    
    # Remove trailing slashes and special chars
    text = re.sub(r'[/\-*]+', ' ', text)
    
    # Final cleanup - remove any remaining isolated special characters
    text = re.sub(r'\s+[/\-*]+\s+', ' ', text)  # Remove isolated slashes/dashes between words
    
    # Clean up multiple spaces again after all replacements
    text = re.sub(r' +', ' ', text)
    
    return text.strip()

def query_with_rag_mobile(
    query: str,
    patient_id: Optional[int] = None,
    max_documents: int = 5,
    similarity_threshold: float = 0.6,
    db: Session = None
) -> Dict:
    """
    Enhanced Query with RAG for Mobile - Friendly, engaging, and longer responses
    
    Optimized for user experience with:
    - Friendlier, more conversational tone
    - Longer, more detailed responses
    - Better explanations and context
    - More engaging and supportive language
    """
    if patient_id is None:
        raise ValueError("patient_id is required for RAG queries")
    
    # Step 1: Search relevant documents
    relevant_docs = []
    try:
        relevant_docs = search_documents(
            query=query,
            patient_id=patient_id,
            limit=max_documents,
            threshold=similarity_threshold,
            db=db
        )
    except Exception as e:
        print(f"Error searching documents: {str(e)}")
    
    # Step 2: Search in medical records
    medical_records_context = []
    try:
        medical_records_context = search_medical_records(
            query=query,
            patient_id=patient_id,
            limit=max_documents,
            db=db
        )
        existing_record_ids = {doc.record_id for doc in relevant_docs if doc.record_id}
        for record in medical_records_context:
            if record.record_id not in existing_record_ids:
                relevant_docs.append(record)
    except Exception as e:
        print(f"Error searching medical records: {str(e)}")
    
    # Step 3: Get patient allergies
    allergies_context = None
    try:
        allergies_context = get_patient_allergies_context(patient_id, db)
    except Exception as e:
        print(f"Error retrieving allergies: {str(e)}")
    
    # Step 3.5: Get health calculations context
    health_calculations_context = None
    try:
        health_calculations_context = get_health_calculations_context(patient_id, db, limit=10)
    except Exception as e:
        print(f"Error retrieving health calculations: {str(e)}")
    
    # Step 3.6: Get health metrics context
    health_metrics_context = None
    try:
        health_metrics_context = get_health_metrics_context(patient_id, db, limit=20)
    except Exception as e:
        print(f"Error retrieving health metrics: {str(e)}")
    
    # Step 4: Sort and limit documents
    relevant_docs.sort(key=lambda x: x.similarity_score, reverse=True)
    relevant_docs = relevant_docs[:max_documents]
    
    # Step 5: Build structured context
    context_parts = []
    sources = []
    
    if allergies_context:
        context_parts.append(allergies_context)
        sources.append("patient_allergies")
    
    if health_calculations_context:
        context_parts.append(health_calculations_context)
        sources.append("health_calculations")
    
    if health_metrics_context:
        context_parts.append(health_metrics_context)
        sources.append("health_metrics")
    
    for doc in relevant_docs:
        metadata_info = ""
        if doc.metadata:
            if doc.metadata.get("visit_date"):
                metadata_info = f"\n[Tanggal: {doc.metadata.get('visit_date')}]"
            if doc.metadata.get("doctor_name"):
                metadata_info += f" [Dokter: {doc.metadata.get('doctor_name')}]"
            if doc.metadata.get("facility_name"):
                metadata_info += f" [Fasilitas: {doc.metadata.get('facility_name')}]"
        
        context_parts.append(f"{doc.chunk_text}{metadata_info}")
        sources.append(doc.doc_id)
    
    if not context_parts:
        return {
            "query": query,
            "answer": "Halo! 😊 Saya tidak menemukan informasi rekam medis atau data kesehatan yang relevan untuk menjawab pertanyaan Anda saat ini. "
                     "Ini bisa terjadi karena: Belum ada dokumen medis yang diunggah. Belum ada riwayat kunjungan medis. "
                     "Belum ada data perhitungan kesehatan (BMI, BMR, TDEE, dll). Pertanyaan Anda memerlukan informasi yang belum tersedia. "
                     "Silakan coba dengan pertanyaan lain atau pastikan Anda telah: Mengunggah dokumen medis. Memiliki riwayat kunjungan medis. "
                     "Menggunakan fitur kalkulator kesehatan untuk menghasilkan data. "
                     "Jika Anda butuh bantuan, jangan ragu untuk menghubungi tim kesehatan kami! 💙",
            "success": False,
            "suggestions": [
                "Apa saja alergi saya?",
                "Kapan terakhir kali saya berobat?",
                "Apa diagnosis terakhir saya?",
                "Obat apa yang sedang saya konsumsi?",
                "Berapa BMI saya saat ini?",
                "Berapa kebutuhan kalori harian saya?",
                "Bagaimana tren berat badan saya?"
            ]
        }
    
    context = "\n\n---\n\n".join(context_parts)
    
    # Step 6: Build friendly, engaging prompt for LLM
    # Simplified and more direct prompt for better reliability with free tier models
    system_prompt = """Anda adalah asisten kesehatan yang ramah untuk aplikasi mobile. 

Tugas Anda:
1. Bantu pasien memahami rekam medis mereka dengan bahasa Indonesia yang RAMAH dan MUDAH DIPAHAMI
2. Berikan penjelasan yang LENGKAP dan DETAIL berdasarkan informasi rekam medis
3. Jelaskan istilah medis dengan bahasa sederhana
4. Tunjukkan kepedulian terhadap kesehatan pasien

PANDUAN JAWABAN:
- Mulai dengan sapaan ramah (contoh: "Halo! 😊" atau "Tentu saja!")
- Gunakan bahasa Indonesia yang natural dan conversational
- Jelaskan informasi dengan detail menggunakan poin-poin jika perlu
- Untuk alergi: Jelaskan dan berikan saran menghindari alergen
- Untuk obat: Sebutkan nama, dosis, frekuensi, dan tips konsumsi
- Untuk hasil lab: Jelaskan nilai, rentang normal, dan artinya
- Untuk diagnosis: Jelaskan dengan bahasa sederhana dan tindakan yang disarankan
- Untuk data perhitungan kesehatan (BMI, BMR, TDEE, dll): Jelaskan nilai, artinya, dan rekomendasi
- Untuk metrik kesehatan: Jelaskan tren, perubahan, dan saran berdasarkan data
- Sebutkan tanggal kunjungan atau perhitungan jika relevan
- Jika informasi tidak tersedia, katakan dengan sopan
- Akhiri dengan dukungan dan saran follow-up

FORMAT RESPONSE:
- Gunakan PLAIN TEXT saja, JANGAN gunakan markdown formatting (tidak boleh **bold**, ### heading, dll)
- JANGAN gunakan karakter khusus seperti / (garis miring), [ ] (kurung siku), atau karakter formatting lainnya
- JANGAN gunakan baris baru (\n) - gunakan tanda titik (.) untuk pemisah kalimat dan paragraf
- Gunakan emoji secukupnya (😊, 💊, 🏥, 💉) - emoji friendly tetap diperbolehkan
- Untuk poin-poin, gunakan angka (1., 2., 3.) dengan spasi, BUKAN tanda strip (-)
- JANGAN gunakan: ** untuk bold, # untuk heading, ``` untuk code block, / untuk formatting, \n untuk newline, dll
- Struktur: Sapaan. Penjelasan. Detail. Tips. Penutup. (gunakan titik untuk pemisah)
- Response akan digunakan untuk Text-to-Speech, jadi semua harus dalam satu paragraf tanpa baris baru
- Gunakan titik (.) dan koma (,) untuk pemisah yang natural, BUKAN baris baru

PENTING:
- Berikan jawaban yang LENGKAP (minimal beberapa kalimat, idealnya 100-200 kata atau lebih)
- Gunakan HANYA informasi dari rekam medis yang diberikan
- Jangan memberikan diagnosis atau saran medis baru
- Jelaskan istilah medis dengan bahasa sederhana
- PASTIKAN response adalah PLAIN TEXT tanpa markdown formatting apapun"""
    
    user_prompt = f"""Berikut adalah rekam medis pasien:

{context}

Pertanyaan pasien: {query}

Instruksi:
- Jawablah pertanyaan dengan RAMAH dan MENYENANGKAN dalam bahasa Indonesia
- Berikan penjelasan yang LENGKAP dan DETAIL
- Gunakan bahasa yang mudah dipahami
- Gunakan PLAIN TEXT saja, JANGAN gunakan markdown (tidak boleh **bold**, ###, dll)
- Jika informasi tersedia, jelaskan dengan jelas
- Jika informasi tidak tersedia, katakan dengan sopan"""
    
    # Step 7: Call LLM with mobile-optimized settings
    try:
        answer = call_llm_with_gemini_mobile(
            query=query,
            context=context,
            system_prompt=system_prompt
        )
        success = True
    except Exception as e:
        error_msg = str(e)
        if "rate limit" in error_msg.lower() or "quota" in error_msg.lower():
            answer = "Maaf, layanan sedang sibuk. Silakan coba lagi beberapa saat lagi. 🙏"
            success = False
        elif "timeout" in error_msg.lower():
            answer = "Maaf, waktu tunggu habis. Silakan coba lagi dengan pertanyaan yang lebih spesifik. ⏱️"
            success = False
        elif "empty" in error_msg or "short" in error_msg:
            answer = "Maaf, saya mengalami kesulitan menghasilkan jawaban yang lengkap untuk pertanyaan Anda. "
            answer += f"Namun, saya menemukan {len(relevant_docs)} dokumen relevan dalam rekam medis Anda. "
            answer += "Silakan coba lagi dengan pertanyaan yang lebih spesifik, atau hubungi tim kesehatan untuk informasi lebih detail. 😔"
            success = False
        else:
            answer = f"Maaf, terjadi kesalahan saat memproses pertanyaan Anda. "
            answer += f"Ditemukan {len(relevant_docs)} dokumen relevan, tetapi tidak dapat menghasilkan jawaban. "
            answer += "Silakan coba lagi dengan pertanyaan yang berbeda atau hubungi administrator. 😔"
            success = False
        print(f"[RAG Mobile] LLM Error: {error_msg}")
    
    # Generate follow-up suggestions
    suggestions = generate_suggestions(query, relevant_docs, allergies_context)
    
    return {
        "query": query,
        "answer": answer,
        "success": success,
        "suggestions": suggestions
    }

def call_llm_with_gemini_mobile(
    query: str,
    context: str,
    system_prompt: str
) -> str:
    """
    Call LLM using Gemini API - Optimized for mobile with Gemini model
    """
    try:
        import google.generativeai as genai
        import time
        
        # Configure Gemini API
        genai.configure(api_key=LLM_API_KEY)
        
        # Get model name - ensure it has 'models/' prefix if not already present
        model_name = LLM_MODEL_NAME or "gemini-2.0-flash"
        if not model_name.startswith("models/"):
            model_name = f"models/{model_name}"
        
        # Limit context if too long (Gemini has token limits)
        # Gemini 2.0 Flash has large context window, but we'll be conservative
        max_context_chars = 80000  # Conservative limit for context
        if len(context) > max_context_chars:
            context_lines = context.split("\n\n---\n\n")
            truncated_context = []
            chars_used = 0
            for line in context_lines:
                if chars_used + len(line) < max_context_chars:
                    truncated_context.append(line)
                    chars_used += len(line)
                else:
                    break
            context = "\n\n---\n\n".join(truncated_context)
            if truncated_context:
                context += "\n\n[Catatan: Beberapa informasi lama tidak ditampilkan untuk menghemat ruang]"
        
        # Build user content with context and query
        user_content = f"""Berikut adalah rekam medis pasien:

{context}

Pertanyaan pasien: {query}

Instruksi:
- Jawablah pertanyaan dengan RAMAH dan MENYENANGKAN dalam bahasa Indonesia
- Berikan penjelasan yang LENGKAP dan DETAIL
- Gunakan bahasa yang mudah dipahami
- Gunakan PLAIN TEXT saja, JANGAN gunakan markdown (tidak boleh **bold**, ###, dll)
- Jika informasi tersedia, jelaskan dengan jelas
- Jika informasi tidak tersedia, katakan dengan sopan"""
        
        max_retries = 3
        for attempt in range(max_retries):
            try:
                # Generate content with Gemini
                # Create model with system instruction
                model = genai.GenerativeModel(
                    model_name=model_name,
                    system_instruction=system_prompt
                )
                
                # Gemini API accepts generation_config as dict
                generation_config = {
                    "temperature": TEMPERATURE,
                    "top_p": 0.95,
                    "top_k": 40,
                    "max_output_tokens": MAX_RESPONSE_TOKENS,
                }
                
                response = model.generate_content(
                    user_content,
                    generation_config=generation_config
                )
                
                # Get answer from response
                if not response or not response.text:
                    raise Exception("Gemini returned empty response")
                
                answer = response.text.strip()
                
                # Remove markdown formatting from answer
                answer = remove_markdown_formatting(answer)
                
                # Log answer for debugging
                print(f"[RAG Mobile] Gemini returned answer: {len(answer)} chars")
                if len(answer) < 100:
                    print(f"[RAG Mobile] Short answer preview: {answer[:200]}")
                
                # Validate answer
                if not answer:
                    raise Exception("Gemini returned empty answer after stripping")
                
                # Accept shorter answers (minimum 10 chars)
                if len(answer) < 10:
                    raise Exception(f"Gemini returned too short answer (only {len(answer)} chars): '{answer}'")
                
                # Log warning if answer is short but acceptable
                if len(answer) < 50:
                    print(f"[RAG Mobile] Warning: Short answer received ({len(answer)} chars), but accepting it")
                
                return answer
                
            except Exception as e:
                error_msg = str(e).lower()
                error_full = str(e)
                
                # Log detailed error for debugging
                print(f"[RAG Mobile] Gemini call error (attempt {attempt + 1}/{max_retries}): {error_full}")
                
                # Check if we should retry
                retryable_errors = ['timeout', 'rate limit', 'quota', 'temporary', 'retry', '503', '502', '429', 'empty', 'short', 'resource_exhausted']
                should_retry = attempt < max_retries - 1 and any(keyword in error_msg for keyword in retryable_errors)
                
                # For empty/short answer errors, try with simpler prompt
                if ('empty' in error_msg or 'short' in error_msg) and attempt < max_retries - 1:
                    print(f"[RAG Mobile] Retrying with simplified prompt due to empty/short answer...")
                    # Simplify the user prompt for retry
                    user_content = f"""Pertanyaan: {query}

Konteks rekam medis:
{context[:1000]}

Jawablah pertanyaan dengan ramah dan jelas dalam bahasa Indonesia. Gunakan PLAIN TEXT saja tanpa markdown."""
                    wait_time = 2
                    time.sleep(wait_time)
                    continue
                elif should_retry:
                    wait_time = (attempt + 1) * 3
                    print(f"[RAG Mobile] Retrying Gemini call after {wait_time} seconds... (attempt {attempt + 1}/{max_retries})")
                    time.sleep(wait_time)
                    continue
                else:
                    # Re-raise with more context
                    raise Exception(f"Gemini call failed after {attempt + 1} attempts: {error_full}")
    
    except ImportError:
        raise Exception("Google Generative AI package not installed. Install with: pip install google-generativeai")
    except Exception as e:
        raise Exception(f"Error calling Gemini API: {str(e)}")

def generate_suggestions(query: str, relevant_docs: List[DocumentChunk], allergies_context: Optional[str]) -> List[str]:
    """Generate follow-up question suggestions based on context"""
    suggestions = []
    
    query_lower = query.lower()
    
    # General suggestions
    if "alergi" in query_lower or "allergy" in query_lower:
        suggestions.extend([
            "Bagaimana cara menghindari alergi ini?",
            "Apa gejala alergi yang harus saya waspadai?",
            "Apakah ada obat untuk alergi ini?"
        ])
    elif "obat" in query_lower or "resep" in query_lower:
        suggestions.extend([
            "Kapan saya harus minum obat ini?",
            "Apa efek samping obat ini?",
            "Bagaimana cara menyimpan obat ini?"
        ])
    elif "lab" in query_lower or "hasil" in query_lower:
        suggestions.extend([
            "Apa artinya hasil lab ini?",
            "Apakah hasil lab saya normal?",
            "Kapan saya harus cek lab lagi?"
        ])
    elif "diagnosis" in query_lower or "diagnosa" in query_lower:
        suggestions.extend([
            "Apa gejala dari diagnosis ini?",
            "Bagaimana cara mengatasi kondisi ini?",
            "Kapan saya harus kontrol lagi?"
        ])
    elif "bmi" in query_lower or "berat" in query_lower or "tinggi" in query_lower:
        suggestions.extend([
            "Berapa berat badan ideal saya?",
            "Bagaimana cara mencapai berat badan ideal?",
            "Berapa kebutuhan kalori harian saya?",
            "Bagaimana tren berat badan saya?"
        ])
    elif "kalori" in query_lower or "bmr" in query_lower or "tdee" in query_lower:
        suggestions.extend([
            "Berapa kebutuhan protein harian saya?",
            "Berapa kebutuhan karbohidrat harian saya?",
            "Bagaimana cara mencapai target kalori?",
            "Berapa kebutuhan air harian saya?"
        ])
    elif "jantung" in query_lower or "heart" in query_lower or "detak" in query_lower:
        suggestions.extend([
            "Berapa detak jantung maksimal saya?",
            "Berapa zona target detak jantung untuk latihan?",
            "Bagaimana cara menjaga kesehatan jantung?"
        ])
    else:
        # Default suggestions
        suggestions.extend([
            "Apa saja alergi saya?",
            "Obat apa yang sedang saya konsumsi?",
            "Kapan terakhir kali saya berobat?",
            "Bagaimana hasil lab terakhir saya?",
            "Berapa BMI saya saat ini?",
            "Berapa kebutuhan kalori harian saya?"
        ])
    
    return suggestions[:4]  # Return max 4 suggestions

