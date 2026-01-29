#!/usr/bin/env python3
"""
RAUST APK Builder - Script para facilitar o build do APK
"""

import os
import subprocess
import sys
from pathlib import Path

def run_command(cmd, description):
    """Executar comando e exibir resultado."""
    print(f"\n{'='*60}")
    print(f"📦 {description}")
    print(f"{'='*60}")
    print(f"Executando: {cmd}\n")
    
    result = subprocess.run(cmd, shell=True)
    if result.returncode != 0:
        print(f"\n❌ Erro ao executar: {description}")
        return False
    
    print(f"\n✅ {description} concluído com sucesso!")
    return True

def check_flutter():
    """Verificar se Flutter está instalado."""
    print("\n🔍 Verificando Flutter...")
    result = subprocess.run("flutter --version", shell=True, capture_output=True, text=True)
    
    if result.returncode == 0:
        print(f"✅ Flutter encontrado:\n{result.stdout}")
        return True
    else:
        print("❌ Flutter não encontrado!")
        print("Instale em: https://flutter.dev/docs/get-started/install")
        return False

def check_android_sdk():
    """Verificar se Android SDK está configurado."""
    print("\n🔍 Verificando Android SDK...")
    result = subprocess.run("flutter doctor", shell=True, capture_output=True, text=True)
    
    if "Android SDK" in result.stdout:
        print("✅ Android SDK encontrado")
        return True
    else:
        print("❌ Android SDK não configurado!")
        return False

def check_google_services():
    """Verificar se google-services.json existe."""
    google_services_path = Path("android/app/google-services.json")
    
    print("\n🔍 Verificando google-services.json...")
    if google_services_path.exists():
        print(f"✅ google-services.json encontrado em: {google_services_path}")
        return True
    else:
        print(f"❌ google-services.json NÃO encontrado!")
        print(f"   Esperado em: {google_services_path}")
        print("\n   Para obter o arquivo:")
        print("   1. Acesse: https://console.firebase.google.com/")
        print("   2. Crie um projeto chamado 'raust-app'")
        print("   3. Adicione um app Android com pacote: com.raust.app")
        print("   4. Baixe google-services.json")
        print("   5. Coloque em: android/app/google-services.json")
        return False

def build_debug_apk():
    """Build APK debug."""
    if not run_command("flutter clean", "Limpando build anterior"):
        return False
    
    if not run_command("flutter pub get", "Instalando dependências"):
        return False
    
    if not run_command("flutter build apk --debug", "Build APK Debug"):
        return False
    
    apk_path = "build/app/outputs/flutter-apk/app-debug.apk"
    if Path(apk_path).exists():
        print(f"\n📱 APK Debug gerado com sucesso!")
        print(f"   Localização: {apk_path}")
        print(f"   Tamanho: {Path(apk_path).stat().st_size / (1024*1024):.2f} MB")
        return True
    else:
        print(f"\n❌ APK não foi gerado em: {apk_path}")
        return False

def build_release_apk():
    """Build APK release."""
    if not run_command("flutter clean", "Limpando build anterior"):
        return False
    
    if not run_command("flutter pub get", "Instalando dependências"):
        return False
    
    if not run_command("flutter build apk --release", "Build APK Release"):
        return False
    
    apk_path = "build/app/outputs/flutter-apk/app-release.apk"
    if Path(apk_path).exists():
        print(f"\n📱 APK Release gerado com sucesso!")
        print(f"   Localização: {apk_path}")
        print(f"   Tamanho: {Path(apk_path).stat().st_size / (1024*1024):.2f} MB")
        return True
    else:
        print(f"\n❌ APK não foi gerado em: {apk_path}")
        return False

def build_app_bundle():
    """Build App Bundle para Google Play Store."""
    if not run_command("flutter clean", "Limpando build anterior"):
        return False
    
    if not run_command("flutter pub get", "Instalando dependências"):
        return False
    
    if not run_command("flutter build appbundle --release", "Build App Bundle"):
        return False
    
    bundle_path = "build/app/outputs/bundle/release/app-release.aab"
    if Path(bundle_path).exists():
        print(f"\n📦 App Bundle gerado com sucesso!")
        print(f"   Localização: {bundle_path}")
        print(f"   Tamanho: {Path(bundle_path).stat().st_size / (1024*1024):.2f} MB")
        return True
    else:
        print(f"\n❌ App Bundle não foi gerado em: {bundle_path}")
        return False

def main():
    """Menu principal."""
    print("\n" + "="*60)
    print("🚀 RAUST APK Builder")
    print("="*60)
    
    # Verificações iniciais
    if not check_flutter():
        sys.exit(1)
    
    if not check_android_sdk():
        print("\n⚠️  Aviso: Android SDK pode não estar totalmente configurado")
    
    if not check_google_services():
        print("\n⚠️  Aviso: google-services.json não encontrado")
        print("   O build pode falhar sem este arquivo!")
    
    # Menu
    print("\n" + "="*60)
    print("Escolha uma opção:")
    print("="*60)
    print("1. Build APK Debug (para testes)")
    print("2. Build APK Release (para produção)")
    print("3. Build App Bundle (para Google Play Store)")
    print("4. Sair")
    print("="*60)
    
    choice = input("\nOpção (1-4): ").strip()
    
    if choice == "1":
        build_debug_apk()
    elif choice == "2":
        build_release_apk()
    elif choice == "3":
        build_app_bundle()
    elif choice == "4":
        print("\nAté logo!")
        sys.exit(0)
    else:
        print("\n❌ Opção inválida!")
        sys.exit(1)

if __name__ == "__main__":
    main()
