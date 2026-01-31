from pydantic_settings import BaseSettings
from pydantic import Field
import os

class Settings(BaseSettings):
    # --- Project Info ---
    PROJECT_NAME: str = "YumDeal Backend"
    VERSION: str = "1.0.0"  # Updated for release
    
    # --- Azure Blob Storage ---
    # Default values map to environment variables passed via docker-compose
    AZURE_STORAGE_ACCOUNT: str = Field(..., env='AZURE_STORAGE_ACCOUNT')
    BLOB_CONTAINER_NAME: str = Field(default="raw-prod", env='BLOB_CONTAINER_NAME')

    # --- Database (Optional/Future Use) ---
    # Not strictly used for ingestion (files go to Blob), but kept for potential direct DB access
    POSTGRES_USER: str = os.getenv("POSTGRES_USER", "yumdeal_user")
    POSTGRES_PASSWORD: str = os.getenv("POSTGRES_PASSWORD", "yumdeal_password")
    POSTGRES_SERVER: str = os.getenv("POSTGRES_SERVER", "postgres")
    POSTGRES_PORT: int = int(os.getenv("POSTGRES_PORT", 5432))
    POSTGRES_DB: str = os.getenv("POSTGRES_DB", "yumdeal")

    @property
    def DATABASE_URL(self) -> str:
        return f"postgresql://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@{self.POSTGRES_SERVER}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"

    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()