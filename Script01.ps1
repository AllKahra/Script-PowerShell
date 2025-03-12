# Caminho das OUs
$ouPathGrupos = "OU=Grupos,DC=anna,DC=local"
$ouPathUsuarios = "OU=Usuarios,DC=anna,DC=local"
$senhaPadrao = "Sherlock#123654"

# Lista de usuários e grupos no formato username;grupo
$username_group = @"
carlos_silva;Desenvolvimento
ana_souza;Desenvolvimento
bruno_costa;Desenvolvimento
mariana_ferreira;Infraestrutura
fernanda_oliveira;Backup
ricardo_martins;Seguranca
camila_rocha;Usuarios
josé_lima;Usuarios
tatiane_mendes;Producao
paulo_andrade;Aplicacoes
juliana_barbosa;Usuarios
gustavo_ramos;Desenvolvimento
vanessa_teixeira;Infraestrutura
roberto_cardoso;Seguranca
letícia_monteiro;Producao
fábio_mendes;Infraestrutura
cristina_almeida;Aplicacoes
lucas_castro;Seguranca
bianca_pereira;Aplicacoes
andré_gonçalves;Seguranca
"@ -split "`n" | ForEach-Object { $_.Trim() }

# Extrair apenas os grupos únicos da lista
$grupos = $username_group | ForEach-Object { 
    $_.Split(';')[1] 
} | Sort-Object -Unique

# Criar os grupos no AD se eles não existirem
Write-Host "=== Criando Grupos ==="
foreach ($grupo in $grupos) {
    if (-not (Get-ADGroup -Filter "Name -eq '$grupo'" -ErrorAction SilentlyContinue)) {
        New-ADGroup -Name $grupo -Path $ouPathGrupos -GroupScope Global
        Write-Host "Grupo $grupo criado com sucesso"
    } else {
        Write-Host "Grupo $grupo já existe"
    }
}

# Criar usuários e adicionar aos grupos
Write-Host "`n=== Criando Usuários e Associando aos Grupos ==="
foreach ($entry in $username_group) {
    # Separar username e grupo
    $usuario, $grupo = $entry.Split(';')

    # Criar usuário se não existir
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$usuario'" -ErrorAction SilentlyContinue)) {
        New-ADUser -SamAccountName $usuario `
                  -UserPrincipalName "$usuario@anna.local" `
                  -Name $usuario `
                  -Enabled $true `
                  -PasswordNeverExpires $false `
                  -AccountPassword (ConvertTo-SecureString -AsPlainText $senhaPadrao -Force) `
                  -ChangePasswordAtLogon $true `
                  -Path $ouPathUsuarios
        
        Write-Host "Usuário $usuario criado com sucesso"
    } else {
        Write-Host "Usuário $usuario já existe"
    }

    # Adicionar usuário ao grupo correspondente
    if (Get-ADGroup -Filter "Name -eq '$grupo'" -ErrorAction SilentlyContinue) {
        Add-ADGroupMember -Identity $grupo -Members $usuario -ErrorAction SilentlyContinue
        Write-Host "Usuário $usuario adicionado ao grupo $grupo"
    } else {
        Write-Host "Grupo $grupo não encontrado para o usuário $usuario"
    }
}