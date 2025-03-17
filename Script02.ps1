# Definir o período de inatividade (em dias)
$DaysInactive = 7
$DateThreshold = (Get-Date).AddDays(-$DaysInactive)

# Obter usuários inativos há mais de 7 dias
$InactiveUsers = Get-ADUser -Filter {LastLogonDate -lt $DateThreshold -and Enabled -eq
$true} -Properties LastLogonDate

# Obter computadores inativos há mais de 7 dias
$InactiveComputers = Get-ADComputer -Filter {LastLogonDate -lt $DateThreshold} -
Properties LastLogonDate

# Criar um relatório para usuários inativos
$UserReport = $InactiveUsers | Select-Object Name, SamAccountName, LastLogonDate, Enabled
| Sort-Object LastLogonDate

# Criar um relatório para computadores inativos
$ComputerReport = $InactiveComputers | Select-Object Name, LastLogonDate, Enabled | Sort-
Object LastLogonDate

# Salvar relatórios em arquivos CSV
$UserReport | Export-Csv -Path "C:\Relatorios\UsuariosInativos.csv" -NoTypeInformation -
Encoding UTF8
$ComputerReport | Export-Csv -Path "C:\Relatorios\ComputadoresInativos.csv" -
NoTypeInformation -Encoding UTF8 

# Escolher ação para usuários (Desativar ou Remover)
$AcaoUsuario = "Desativar" # Alterar para "Remover" se desejar excluir usuários

If ($AcaoUsuario -eq "Desativar") {
    $InactiveUsers | ForEach-Object { Disable-ADUser -Identity $_.SamAccountName }
} ElseIf ($AcaoUsuario -eq "Remover") {
    $InactiveUsers | ForEach-Object { Remove-ADUser -Identity $_.SamAccountName 
Confirm:$false }
}

# Escolher ação para computadores (Desativar ou Remover)
$AcaoComputador = "Desativar" # Alterar para "Remover" se desejar excluir computadores

If ($AcaoComputador -eq "Desativar") {
    $InactiveComputers | ForEach-Object { Disable-ADAccount -Identity $_.Name }
} ElseIf ($AcaoComputador -eq "Remover") {
    $InactiveComputers | ForEach-Object { Remove-ADComputer -Identity $_.Name -
Confirm:$false }
}

# Configurar informações do e-mail
$AdminEmail = "administrator@anna.local"
$FromEmail = "notificacoes@anna.local "
$SMTPServer = "smtp.anna.local "

# Corpo do e-mail
$EmailBody = @"

Relatorio de Contas Inativas

Usuarios Inativos: $($UserReport.Count)
Computadores Inativos: $($ComputerReport.Count)

Acao realizada:
Usuarios - $AcaoUsuario
Computadores - $AcaoComputador

Os relatorios detalhados estao anexados.
"@

# Enviar e-mail com os relatórios anexados
Send-MailMessage -To $AdminEmail -From $FromEmail -Subject "Relatorio de Contas Inativas"
-Body $EmailBody -SmtpServer $SMTPServer -Attachments
"C:\Relatorios\UsuariosInativos.csv", "C:\Relatorios\ComputadoresInativos.csv"