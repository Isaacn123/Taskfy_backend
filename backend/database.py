import sqlalchemy as _sql
import sqlalchemy.ext.declarative as _declarative
import sqlalchemy.orm as _orm
import os
from dotenv import load_dotenv
# import models as _mo
#DATABASE_URL = "postgresql://USER:PASSWORD@localhost:5432/DATABASE_NAME"

# OLD SQLITE CONFIGURATION (COMMENTED OUT)
# DATABASE_URL = "sqlite:///./database.db"
# DATABASE_URL = "postgresql://user:password@localhost:5432/taskify_db"
# DATABASE_URL = os.getenv("DATABASE_URL","postgresql://user:password@localhost:5432/database.db")
# load_dotenv()
# DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./database_.db")
# engine = _sql.create_engine(DATABASE_URL,connect_args={"check_same_thread":False})
# if DATABASE_URL.startswith("sqlite"):
#     engine = _sql.create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
# else:
#     engine = _sql.create_engine(DATABASE_URL)  # for postgress we dont need the string "check_same_thread" its for sqlite

# NEW MYSQL CONFIGURATION
load_dotenv()

# Build DATABASE_URL from environment variables
MYSQL_USER = os.getenv("MYSQL_USER", "taskify_user")
MYSQL_PASSWORD = os.getenv("MYSQL_PASSWORD", "taskify_password")
MYSQL_HOST = os.getenv("MYSQL_HOST", "db")
MYSQL_PORT = os.getenv("MYSQL_PORT", "3306")
MYSQL_DATABASE = os.getenv("MYSQL_DATABASE", "taskify_db")

# Use environment variable or build from components
DATABASE_URL = os.getenv("DATABASE_URL") or f"mysql+pymysql://{MYSQL_USER}:{MYSQL_PASSWORD}@{MYSQL_HOST}:{MYSQL_PORT}/{MYSQL_DATABASE}"

# Create engine with MySQL configuration
engine = _sql.create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
    pool_recycle=300,
    echo=False  # Set to True for SQL query logging
)
SessionLocal = _orm.sessionmaker(autocommit=False,autoflush=False,bind=engine)
Base = _declarative.declarative_base()



