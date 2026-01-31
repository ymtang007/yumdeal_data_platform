import uuid
import json
from datetime import datetime
from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient

# Import schemas for validation
from app.schemas import DealPayload
from app.config import settings

app = FastAPI(title="YumDeal Data Lake Ingestion")

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    # In production, recommend changing "*" to the specific Chrome Extension ID
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Initialize Azure Blob Client ---
blob_service_client = None
container_client = None

@app.on_event("startup")
async def startup_event():
    global blob_service_client, container_client
    try:
        print(f"Connecting to Azure Storage: {settings.AZURE_STORAGE_ACCOUNT}")
        
        # Construct Blob URL
        blob_url = f"https://{settings.AZURE_STORAGE_ACCOUNT}.blob.core.windows.net"
        
        # Use Managed Identity (No password needed, uses Azure VM identity automatically)
        credential = DefaultAzureCredential()
        
        blob_service_client = BlobServiceClient(account_url=blob_url, credential=credential)
        container_client = blob_service_client.get_container_client(settings.BLOB_CONTAINER_NAME)
        
        print(f"Connected to container: {settings.BLOB_CONTAINER_NAME}")
        
    except Exception as e:
        print(f"Error connecting to Azure: {e}")
        # Note: We do not crash the app here to allow debugging, but ingest will fail.

@app.get("/")
def health_check():
    return {
        "status": "active", 
        "target": "Azure Blob Storage", 
        "container": settings.BLOB_CONTAINER_NAME,
        "version": settings.VERSION
    }

@app.post("/api/v1/ingest")
async def ingest_deals(payload: DealPayload):
    """
    Receives data from Extension -> Validates -> Saves to Azure Data Lake
    """
    if not container_client:
        raise HTTPException(status_code=500, detail="Storage connection not initialized")

    try:
        # 1. Prepare file content (Convert Pydantic model to Dict then JSON)
        # mode='json' ensures types like datetime are serialized correctly
        data_dict = payload.model_dump(mode='json')
        data_str = json.dumps(data_dict, ensure_ascii=False)
        
        # 2. Generate file path (Partitioning: raw/YYYY/MM/DD/{uuid}.json)
        now = datetime.utcnow()
        date_path = now.strftime("%Y/%m/%d")
        file_id = str(uuid.uuid4())
        blob_name = f"raw/{date_path}/{file_id}.json"
        
        # 3. Upload to Blob
        blob_client = container_client.get_blob_client(blob_name)
        blob_client.upload_blob(data_str, overwrite=True)
        
        print(f"Saved: {blob_name}")
        
        return {
            "status": "success",
            "file_id": file_id,
            "path": blob_name,
            "message": "Data secured in Azure Lake"
        }

    except Exception as e:
        print(f"Ingest Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))