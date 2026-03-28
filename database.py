from sqlalchemy import create_engine, Column, Integer, String, Date, ForeignKey
from sqlalchemy.orm import declarative_base, sessionmaker

# 1. Database ka address (Apni local hard drive par ek file banegi tasks.db)
SQLALCHEMY_DATABASE_URL = "sqlite:///./tasks.db"

# 2. Engine ban banana (Jo database se baat karega)
engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)

# 3. Session banana (Ek temporary connection)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# 4. Base class jisse humari tables banengi
Base = declarative_base()

# 5. Apni Task Table ka Design
class TaskDB(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    description = Column(String)
    due_date = Column(Date)
    status = Column(String, default="To-Do") # "To-Do", "In Progress", "Done"
    blocked_by = Column(Integer, ForeignKey("tasks.id"), nullable=True) # Optional link

# 6. Ye line database aur table ko actually create kar degi
Base.metadata.create_all(bind=engine)