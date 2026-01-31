from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.config import settings

# 1. Create Database Engine
# pool_pre_ping=True checks connection health before checkout, 
# preventing "server closed the connection unexpectedly" errors.
engine = create_engine(
    settings.DATABASE_URL,
    pool_pre_ping=True
)

# 2. Create Session Factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# 3. Dependency
# Used to yield a database session per request and close it automatically
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()