"""
Script to run FastAPI services with enhanced logging and colors
"""
import uvicorn
import argparse
import subprocess
import sys
import os
import threading
import time
import re

# ANSI Color Codes
class Colors:
    """ANSI color codes for terminal output"""
    # Reset
    RESET = '\033[0m'
    
    # Service Colors
    AUTH_COLOR = '\033[94m'  # Bright Blue
    RM_COLOR = '\033[92m'    # Bright Green
    RAG_COLOR = '\033[95m'   # Bright Magenta
    RAG_MOBILE_COLOR = '\033[96m'  # Bright Cyan
    RM_MOBILE_COLOR = '\033[93m'  # Bright Yellow
    HEALTH_CALC_COLOR = '\033[91m'  # Bright Red
    
    # Status Colors
    SUCCESS = '\033[92m'     # Green
    WARNING = '\033[93m'     # Yellow
    ERROR = '\033[91m'       # Red
    INFO = '\033[96m'        # Cyan
    
    # Text Colors
    RED = '\033[91m'
    YELLOW = '\033[93m'
    GREEN = '\033[92m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'

def get_service_color(prefix):
    """Get color code for service prefix"""
    prefix_clean = prefix.strip()
    if prefix_clean == "AUTH":
        return Colors.AUTH_COLOR
    elif prefix_clean == "RM":
        return Colors.RM_COLOR
    elif prefix_clean == "RAG":
        return Colors.RAG_COLOR
    elif prefix_clean == "RAG_MOBILE" or prefix_clean == "RAG MOBILE":
        return Colors.RAG_MOBILE_COLOR
    elif prefix_clean == "RM_MOBILE" or prefix_clean == "RM MOBILE":
        return Colors.RM_MOBILE_COLOR
    elif prefix_clean == "HEALTH_CALC" or prefix_clean == "HEALTH CALC":
        return Colors.HEALTH_CALC_COLOR
    else:
        return Colors.RESET

def is_error_line(line):
    """Check if line contains error indicators"""
    error_patterns = [
        r'500',
        r'Internal Server Error',
        r'ERROR',
        r'Error:',
        r'Exception',
        r'Traceback',
        r'Failed',
        r'crashed',
        r'❌',
        r'⚠️',
        r'error',
        r'Error calling',
        r'ConnectionError',
        r'TimeoutError',
    ]
    line_lower = line.lower()
    for pattern in error_patterns:
        if re.search(pattern, line_lower, re.IGNORECASE):
            return True
    return False

def print_stream(stream, prefix):
    """Print stream output with prefix and color coding"""
    service_color = get_service_color(prefix)
    try:
        for line in iter(stream.readline, ''):
            if line:
                line_stripped = line.rstrip()
                
                # Check if line contains errors
                if is_error_line(line_stripped):
                    # Print error in red
                    print(f"{service_color}[{prefix}]{Colors.RESET} {Colors.ERROR}{line_stripped}{Colors.RESET}")
                else:
                    # Print normal line with service color
                    print(f"{service_color}[{prefix}]{Colors.RESET} {line_stripped}")
    except Exception as e:
        print(f"{service_color}[{prefix}]{Colors.RESET} {Colors.ERROR}Error reading stream: {e}{Colors.RESET}")

def run_auth_service():
    """Run Authentication Service"""
    print(f"{Colors.AUTH_COLOR}✅ Starting Authentication Service on http://0.0.0.0:8000{Colors.RESET}")
    print(f"{Colors.AUTH_COLOR}   Docs: http://localhost:8000/docs{Colors.RESET}")
    print("-" * 60)
    uvicorn.run(
        "auth.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )

def run_rm_service():
    """Run Medical Records Service"""
    print(f"{Colors.RM_COLOR}✅ Starting Medical Records Service on http://0.0.0.0:8001{Colors.RESET}")
    print(f"{Colors.RM_COLOR}   Docs: http://localhost:8001/docs{Colors.RESET}")
    print("-" * 60)
    uvicorn.run(
        "rm_service.main:app",
        host="0.0.0.0",
        port=8001,
        reload=True,
        log_level="info"
    )

def run_rag_service():
    """Run RAG Service (Admin/Doctor/Staff Only)"""
    print(f"{Colors.RAG_COLOR}✅ Starting RAG Service (Admin/Doctor/Staff) on http://0.0.0.0:8002{Colors.RESET}")
    print(f"{Colors.RAG_COLOR}   Docs: http://localhost:8002/docs{Colors.RESET}")
    print("-" * 60)
    uvicorn.run(
        "rag_service.main:app",
        host="0.0.0.0",
        port=8002,
        reload=True,
        log_level="info"
    )

def run_rag_mobile_service():
    """Run RAG Service Mobile (User Only)"""
    print(f"{Colors.RAG_MOBILE_COLOR}✅ Starting RAG Service Mobile (User) on http://0.0.0.0:8004{Colors.RESET}")
    print(f"{Colors.RAG_MOBILE_COLOR}   Docs: http://localhost:8004/docs{Colors.RESET}")
    print("-" * 60)
    uvicorn.run(
        "rag_service_mobile.main:app",
        host="0.0.0.0",
        port=8004,
        reload=True,
        log_level="info"
    )

def run_health_calculator_service():
    """Run Health Calculator Service (User Only)"""
    print(f"{Colors.HEALTH_CALC_COLOR}✅ Starting Health Calculator Service (User) on http://0.0.0.0:8005{Colors.RESET}")
    print(f"{Colors.HEALTH_CALC_COLOR}   Docs: http://localhost:8005/docs{Colors.RESET}")
    print("-" * 60)
    uvicorn.run(
        "health_calculator_service.main:app",
        host="0.0.0.0",
        port=8005,
        reload=True,
        log_level="info"
    )

def run_rm_mobile_service():
    """Run RM Service Mobile"""
    print(f"{Colors.RM_MOBILE_COLOR}✅ Starting RM Service Mobile on http://0.0.0.0:8003{Colors.RESET}")
    print(f"{Colors.RM_MOBILE_COLOR}   Docs: http://localhost:8003/docs{Colors.RESET}")
    print("-" * 60)
    uvicorn.run(
        "rm_service_mobile.main:app",
        host="0.0.0.0",
        port=8003,
        reload=True,
        log_level="info"
    )

def run_all():
    """Run all services using subprocess with real-time logging"""
    print("=" * 60)
    print(f"{Colors.INFO}Starting All Services{Colors.RESET}")
    print("=" * 60)
    print(f"{Colors.AUTH_COLOR}Auth Service:{Colors.RESET}          http://0.0.0.0:8000  (Docs: http://localhost:8000/docs)")
    print(f"{Colors.RM_COLOR}RM Service (Admin):{Colors.RESET}      http://0.0.0.0:8001  (Docs: http://localhost:8001/docs)")
    print(f"{Colors.RAG_COLOR}RAG Service (Admin):{Colors.RESET}    http://0.0.0.0:8002  (Docs: http://localhost:8002/docs)")
    print(f"{Colors.RM_MOBILE_COLOR}RM Mobile Service (User):{Colors.RESET}  http://0.0.0.0:8003  (Docs: http://localhost:8003/docs)")
    print(f"{Colors.RAG_MOBILE_COLOR}RAG Mobile Service (User):{Colors.RESET} http://0.0.0.0:8004  (Docs: http://localhost:8004/docs)")
    print(f"{Colors.HEALTH_CALC_COLOR}Health Calculator Service (User):{Colors.RESET} http://0.0.0.0:8005  (Docs: http://localhost:8005/docs)")
    print("=" * 60)
    print("Starting services with real-time logging...")
    print("Press Ctrl+C to stop all services")
    print("-" * 60)
    print()
    
    # Start auth service in background with real-time output
    auth_process = subprocess.Popen(
        [sys.executable, __file__, "--service", "auth"],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,  # Combine stderr with stdout
        universal_newlines=True,
        bufsize=1  # Line buffered
    )
    
    # Start rm service in background with real-time output
    rm_process = subprocess.Popen(
        [sys.executable, __file__, "--service", "rm"],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,  # Combine stderr with stdout
        universal_newlines=True,
        bufsize=1  # Line buffered
    )
    
    # Start rag service in background with real-time output
    rag_process = subprocess.Popen(
        [sys.executable, __file__, "--service", "rag"],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,  # Combine stderr with stdout
        universal_newlines=True,
        bufsize=1  # Line buffered
    )
    
    # Start rm_mobile service in background with real-time output
    rm_mobile_process = subprocess.Popen(
        [sys.executable, __file__, "--service", "rm_mobile"],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,  # Combine stderr with stdout
        universal_newlines=True,
        bufsize=1  # Line buffered
    )
    
    # Start rag_mobile service in background with real-time output
    rag_mobile_process = subprocess.Popen(
        [sys.executable, __file__, "--service", "rag_mobile"],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,  # Combine stderr with stdout
        universal_newlines=True,
        bufsize=1  # Line buffered
    )
    
    # Start health_calculator service in background with real-time output
    health_calc_process = subprocess.Popen(
        [sys.executable, __file__, "--service", "health_calc"],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,  # Combine stderr with stdout
        universal_newlines=True,
        bufsize=1  # Line buffered
    )
    
    # Create threads to print logs in real-time
    auth_thread = threading.Thread(
        target=print_stream,
        args=(auth_process.stdout, "AUTH"),
        daemon=True
    )
    rm_thread = threading.Thread(
        target=print_stream,
        args=(rm_process.stdout, "RM  "),
        daemon=True
    )
    rag_thread = threading.Thread(
        target=print_stream,
        args=(rag_process.stdout, "RAG "),
        daemon=True
    )
    rm_mobile_thread = threading.Thread(
        target=print_stream,
        args=(rm_mobile_process.stdout, "RM_MOBILE"),
        daemon=True
    )
    rag_mobile_thread = threading.Thread(
        target=print_stream,
        args=(rag_mobile_process.stdout, "RAG_MOBILE"),
        daemon=True
    )
    health_calc_thread = threading.Thread(
        target=print_stream,
        args=(health_calc_process.stdout, "HEALTH_CALC"),
        daemon=True
    )
    
    auth_thread.start()
    rm_thread.start()
    rag_thread.start()
    rm_mobile_thread.start()
    rag_mobile_thread.start()
    health_calc_thread.start()
    
    try:
        # Monitor processes
        while True:
            auth_status = auth_process.poll()
            rm_status = rm_process.poll()
            rag_status = rag_process.poll()
            rm_mobile_status = rm_mobile_process.poll()
            rag_mobile_status = rag_mobile_process.poll()
            health_calc_status = health_calc_process.poll()
            
            if auth_status is not None:
                if auth_status != 0:
                    print(f"\n{Colors.AUTH_COLOR}[AUTH]{Colors.RESET} {Colors.ERROR}⚠️  Service stopped with exit code {auth_status}{Colors.RESET}")
                    print(f"{Colors.AUTH_COLOR}[AUTH]{Colors.RESET} {Colors.ERROR}❌ Service crashed! Check logs above for errors.{Colors.RESET}")
                else:
                    print(f"\n{Colors.AUTH_COLOR}[AUTH]{Colors.RESET} {Colors.WARNING}⚠️  Service stopped with exit code {auth_status}{Colors.RESET}")
            
            if rm_status is not None:
                if rm_status != 0:
                    print(f"\n{Colors.RM_COLOR}[RM]{Colors.RESET} {Colors.ERROR}⚠️  Service stopped with exit code {rm_status}{Colors.RESET}")
                    print(f"{Colors.RM_COLOR}[RM]{Colors.RESET} {Colors.ERROR}❌ Service crashed! Check logs above for errors.{Colors.RESET}")
                else:
                    print(f"\n{Colors.RM_COLOR}[RM]{Colors.RESET} {Colors.WARNING}⚠️  Service stopped with exit code {rm_status}{Colors.RESET}")
            
            if rag_status is not None:
                if rag_status != 0:
                    print(f"\n{Colors.RAG_COLOR}[RAG]{Colors.RESET} {Colors.ERROR}⚠️  Service stopped with exit code {rag_status}{Colors.RESET}")
                    print(f"{Colors.RAG_COLOR}[RAG]{Colors.RESET} {Colors.ERROR}❌ Service crashed! Check logs above for errors.{Colors.RESET}")
                else:
                    print(f"\n{Colors.RAG_COLOR}[RAG]{Colors.RESET} {Colors.WARNING}⚠️  Service stopped with exit code {rag_status}{Colors.RESET}")
            
            if rm_mobile_status is not None:
                if rm_mobile_status != 0:
                    print(f"\n{Colors.RM_MOBILE_COLOR}[RM_MOBILE]{Colors.RESET} {Colors.ERROR}⚠️  Service stopped with exit code {rm_mobile_status}{Colors.RESET}")
                    print(f"{Colors.RM_MOBILE_COLOR}[RM_MOBILE]{Colors.RESET} {Colors.ERROR}❌ Service crashed! Check logs above for errors.{Colors.RESET}")
                else:
                    print(f"\n{Colors.RM_MOBILE_COLOR}[RM_MOBILE]{Colors.RESET} {Colors.WARNING}⚠️  Service stopped with exit code {rm_mobile_status}{Colors.RESET}")
            
            if rag_mobile_status is not None:
                if rag_mobile_status != 0:
                    print(f"\n{Colors.RAG_MOBILE_COLOR}[RAG_MOBILE]{Colors.RESET} {Colors.ERROR}⚠️  Service stopped with exit code {rag_mobile_status}{Colors.RESET}")
                    print(f"{Colors.RAG_MOBILE_COLOR}[RAG_MOBILE]{Colors.RESET} {Colors.ERROR}❌ Service crashed! Check logs above for errors.{Colors.RESET}")
                else:
                    print(f"\n{Colors.RAG_MOBILE_COLOR}[RAG_MOBILE]{Colors.RESET} {Colors.WARNING}⚠️  Service stopped with exit code {rag_mobile_status}{Colors.RESET}")
            
            if health_calc_status is not None:
                if health_calc_status != 0:
                    print(f"\n{Colors.HEALTH_CALC_COLOR}[HEALTH_CALC]{Colors.RESET} {Colors.ERROR}⚠️  Service stopped with exit code {health_calc_status}{Colors.RESET}")
                    print(f"{Colors.HEALTH_CALC_COLOR}[HEALTH_CALC]{Colors.RESET} {Colors.ERROR}❌ Service crashed! Check logs above for errors.{Colors.RESET}")
                else:
                    print(f"\n{Colors.HEALTH_CALC_COLOR}[HEALTH_CALC]{Colors.RESET} {Colors.WARNING}⚠️  Service stopped with exit code {health_calc_status}{Colors.RESET}")
            
            if auth_status is not None and rm_status is not None and rag_status is not None and rm_mobile_status is not None and rag_mobile_status is not None and health_calc_status is not None:
                print("\n🛑 All services have stopped.")
                break
            
            time.sleep(1)
            
    except KeyboardInterrupt:
        print(f"\n\n{Colors.WARNING}🛑 Stopping all services...{Colors.RESET}")
        if auth_process.poll() is None:
            auth_process.terminate()
            try:
                auth_process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                auth_process.kill()
                auth_process.wait()
        
        if rm_process.poll() is None:
            rm_process.terminate()
            try:
                rm_process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                rm_process.kill()
                rm_process.wait()
        
        if rag_process.poll() is None:
            rag_process.terminate()
            try:
                rag_process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                rag_process.kill()
                rag_process.wait()
        
        if rm_mobile_process.poll() is None:
            rm_mobile_process.terminate()
            try:
                rm_mobile_process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                rm_mobile_process.kill()
                rm_mobile_process.wait()
        
        if rag_mobile_process.poll() is None:
            rag_mobile_process.terminate()
            try:
                rag_mobile_process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                rag_mobile_process.kill()
                rag_mobile_process.wait()
        
        if health_calc_process.poll() is None:
            health_calc_process.terminate()
            try:
                health_calc_process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                health_calc_process.kill()
                health_calc_process.wait()
        
        print(f"{Colors.SUCCESS}✅ All services stopped{Colors.RESET}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run FastAPI services")
    parser.add_argument(
        "--service",
        type=str,
        choices=["auth", "rm", "rag", "rm_mobile", "rag_mobile", "health_calc"],
        help="Service to run: auth, rm, rag, rm_mobile, rag_mobile, or health_calc (use without flag to run all)"
    )
    
    args = parser.parse_args()
    
    if args.service == "auth":
        run_auth_service()
    elif args.service == "rm":
        run_rm_service()
    elif args.service == "rag":
        run_rag_service()
    elif args.service == "rm_mobile":
        run_rm_mobile_service()
    elif args.service == "rag_mobile":
        run_rag_mobile_service()
    elif args.service == "health_calc":
        run_health_calculator_service()
    else:
        # Default: run all
        run_all()
