# 🔥 Como Ativar o Firebase Storage

## ✅ Status Atual
- ✅ Firebase configurado: **borae-34b9e**
- ✅ Authentication: Configurado
- ✅ Firestore: Configurado
- ⚠️ Storage: **PRECISA SER ATIVADO**

---

## 📝 Passo a Passo para Ativar o Storage

### **1. Acessar Firebase Console**

1. Abra o navegador
2. Acesse: https://console.firebase.google.com/
3. Selecione o projeto: **borae** (borae-34b9e)

### **2. Ativar Storage**

1. No menu lateral esquerdo, clique em **"Build"** → **"Storage"**
2. Clique no botão **"Get started"** ou **"Começar"**
3. Você verá uma tela com as regras de segurança padrão

### **3. Configurar Regras de Segurança (Primeira Tela)**

Na primeira tela, você verá:

```
Proteja seus dados do Cloud Storage
```

**Escolha uma opção:**
- **Recomendado:** Selecione **"Começar no modo de teste"** (test mode)
- Clique em **"Avançar"** ou **"Next"**

### **4. Escolher Localização (Segunda Tela)**

```
Onde você quer armazenar seus dados?
```

**Selecione:**
- Região: **southamerica-east1** (São Paulo)
- Clique em **"Concluir"** ou **"Done"**

⏳ **Aguarde 1-2 minutos** enquanto o Storage é criado.

### **5. Configurar Regras de Segurança Personalizadas**

Após criar, você verá a interface do Storage. Agora vamos configurar regras mais específicas:

1. Clique na aba **"Rules"** (Regras) no topo
2. **SUBSTITUA** todo o código por este:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // === REGRAS PARA IMAGENS DE EVENTOS ===
    match /event_images/{imageId} {
      // Todos podem visualizar imagens
      allow read: if true;
      
      // Apenas usuários autenticados podem fazer upload
      // Tamanho máximo: 5MB
      // Apenas arquivos de imagem
      allow write: if request.auth != null && 
                      request.resource.size < 5 * 1024 * 1024 && 
                      request.resource.contentType.matches('image/.*');
    }
    
    // === REGRAS PARA FOTOS DE PERFIL (FUTURO) ===
    match /profile_images/{userId}/{imageId} {
      allow read: if true;
      
      // Apenas o próprio usuário pode fazer upload da sua foto
      allow write: if request.auth != null && 
                      request.auth.uid == userId &&
                      request.resource.size < 2 * 1024 * 1024 &&
                      request.resource.contentType.matches('image/.*');
    }
  }
}
```

3. Clique em **"Publicar"** ou **"Publish"**

---

## ✅ Verificar se Storage Está Funcionando

### **Teste 1: Criar Evento com Imagem**

1. Execute o app: `flutter run -d chrome`
2. Faça login como **Organizador**
3. Vá em **"Criar Evento"**
4. Preencha os dados e adicione uma imagem
5. Clique em **"Criar Evento"**

### **Teste 2: Verificar Upload no Console**

1. Volte ao Firebase Console → Storage
2. Clique em **"Files"** (Arquivos)
3. Você deve ver a pasta **event_images/**
4. Dentro dela, a imagem que você fez upload

---

## 🔍 Troubleshooting

### **Erro: "storage/unauthorized"**

**Causa:** Regras de segurança muito restritivas

**Solução Temporária:**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true; // ATENÇÃO: Apenas para testes!
    }
  }
}
```

### **Erro: "storage/quota-exceeded"**

**Causa:** Limite de armazenamento gratuito excedido (5GB no plano gratuito)

**Solução:** 
- Delete arquivos desnecessários no Storage
- Ou atualize para o plano Blaze (pague conforme o uso)

### **Storage não aparece no menu**

**Causa:** Ainda não foi ativado para este projeto

**Solução:**
1. No Firebase Console, vá em **"Project Settings"** (Configurações do projeto)
2. Vá na aba **"General"**
3. Verifique se o projeto está no plano correto
4. Tente novamente ativar o Storage

---

## 📊 Informações do Projeto

- **Nome do Projeto:** borae
- **ID do Projeto:** borae-34b9e
- **Project Number:** 611650116188
- **Região Recomendada:** southamerica-east1 (São Paulo)

### Apps Configurados:

| Plataforma | Firebase App ID |
|------------|----------------|
| Web        | 1:611650116188:web:0c25fab6aba671cef82499 |
| Android    | 1:611650116188:android:f8fb78a17e89dd6ff82499 |
| iOS        | 1:611650116188:ios:cc05ae053e5dbd0cf82499 |
| macOS      | 1:611650116188:ios:cc05ae053e5dbd0cf82499 |
| Windows    | 1:611650116188:web:5f8a96626716589df82499 |

---

## 🎯 Após Ativar o Storage

Seu app estará **100% funcional** com todas as features:

- ✅ Autenticação de usuários
- ✅ Criar eventos
- ✅ Upload de imagens de eventos
- ✅ Listar eventos com imagens
- ✅ Comprar ingressos
- ✅ Ver meus ingressos
- ✅ Todos os dados salvos no Firebase

---

**⚡ Ação Rápida:**

1. Acesse: https://console.firebase.google.com/project/borae-34b9e/storage
2. Clique em "Get started"
3. Escolha "Modo de teste"
4. Região: southamerica-east1
5. Clique em "Concluir"

**Pronto! 🎉**
