# 📜 PSDirectus

## 🌍 Overview
PSDirectus is a PowerShell module designed to interact with the Directus API. It provides an easy-to-use interface for authentication, querying items, and performing CRUD (Create, Read, Update, Delete) operations on Directus collections & files.

## 🎯 Features

### ✅ Implemented Features
- 🔑 **Token & Context Management**
  - `New-PSDirectusContext` : Initializes a Directus API context with a base URL and authentication token.
- 📝 **Item Management (CRUD)** 
  - `Get-PSDirectusItem` : Fetches a single item from a Directus collection.
  - `Get-PSDirectusItemSingleton` : Retrieves a singleton item from a Directus collection.
  - `New-PSDirectusItem` : Creates a new item in a Directus collection.
  - `New-PSDirectusItems` : Bulk creates multiple items in a Directus collection.
  - `Update-PSDirectusItem` : Updates a single item in a Directus collection.
  - `Update-PSDirectusItems` : Bulk updates multiple items.
  - `Update-PSDirectusItemSingleton` : Updates a singleton item.
  - `Remove-PSDirectusItem` 🗑️: Deletes a single item from a Directus collection.
  - `Remove-PSDirectusItems` 🗑️📦: Bulk deletes multiple items.
- 📂 **File Management (CRUD)**
  - `Get-PSDirectusFile` : Retrieves file details from Directus.
  - `New-PSDirectusFile` : Uploads a new file.
  - `Remove-PSDirectusFile` : Deletes a single file.
  - `Remove-PSDirectusFiles` : Bulk deletes multiple files.
  - `Update-PSDirectusFile` : Updates a file’s metadata.
  - `Update-PSDirectusFiles` : Bulk updates multiple files.
  - `Import-PSDirectusFile` : Imports an external file into Directus.
- 🔍 **Filtering**
  - `New-PSDirectusFilter` : Constructs API query filters.

### 🚧 Not Yet Implemented
- **Endpoints**
  - The following endpoints are not currently implemented:
    ```
    /comments  
    /dashboards
    /extensions
    /fields  
    /flows       
    /folders    
    /metrics    
    /notifications  
    /operations   
    /panels      
    /permissions  
    /policies    
    /presets     
    /relations    
    /revisions     
    /roles      
    /schema        
    /server        
    /settings      
    /shares       
    /translations  
    /users     
    /utilities    
    /versions   
    ```
- **JWT Authentication**
  - There's currently no option for username/password authentication with a returned JWT/refresh token.
- **User, & Role Management**
  - No functions currently exist for managing users, roles, or permissions.
- **Custom Endpoints & Extensions**
  - No support for executing custom Directus endpoints or extensions.
- **Batch Operations with Transactions**
  - No explicit transaction support for batch operations.

## 🖥️ Example Usage

### 🔹 Initialize Context
```powershell
$context = New-PSDirectusContext -BaseURL "https://your-directus-instance.com" -Token "your-api-token"
```

### 🔹 Fetch an Item
```powershell
$item = Get-PSDirectusItem -Context $context -Collection "articles" -ID 1
```

### 🔹 Create a New Item
```powershell
$newItem = New-PSDirectusItem -Context $context -Collection "articles" -Data @{ title = "New Article" }
```

## 🤝 Contributing
Contributions are welcome! Feel free to open issues or submit pull requests to enhance functionality. 🎉👨‍💻🚀

