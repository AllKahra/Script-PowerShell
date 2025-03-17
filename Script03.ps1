# Caminho dos arquivos
$csvFile = "C:\Relatorios\usuarios_desligados.csv"  
$logFile = "C:\Relatorios\log_desativacao.txt"    

# Importar a lista de usuários desligados do CSV
$usuarios = Import-Csv -Path $csvFile

# Processar cada usuário da lista
foreach ($usuario in $usuarios) {
    $nome = $usuario.usuario_desligado  # Captura o valor da coluna 'usuario_desligado'

    # Verificar se o usuário existe no Active Directory
    $adUser = Get-ADUser -Filter {SamAccountName -eq $nome} -ErrorAction SilentlyContinue

    if ($adUser) {
        # Desativar a conta do usuário
        Disable-ADAccount -Identity $adUser.SamAccountName
        # Registrar sucesso no log com data e hora
        Add-Content -Path $logFile -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Usuário $nome desativado com sucesso."
    } else {
        # Registrar erro no log se o usuário não for encontrado
        Add-Content -Path $logFile -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] ERRO: Usuário $nome não encontrado no AD."
    }
}

# Mensagem de conclusão no console
Write-Host "Processamento concluído. Verifique o log em $logFile"