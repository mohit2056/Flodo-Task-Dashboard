from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI, Depends, HTTPException # type: ignore
from sqlalchemy.orm import Session   # type: ignore # <--- Ye line add karni hai
from pydantic import BaseModel # type: ignore
from typing import List, Optional
from datetime import date
import asyncio
import database # Humari database.py file link ho rahi hai

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Iska matlab koi bhi frontend humari API use kar sakta hai
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- 1. PYDANTIC MODELS (Ye check karega ki user sahi data bhej raha hai ya nahi) ---
class TaskBase(BaseModel):
    title: str
    description: str
    due_date: date
    status: str = "To-Do"
    blocked_by: Optional[int] = None # Optional hai

class TaskCreate(TaskBase):
    pass

class TaskResponse(TaskBase):
    id: int
    class Config:
        from_attributes = True

# --- 2. DATABASE CONNECTION FUNCTION ---
def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/")
def home():
    return {"message": "Flodo AI Backend Ready! Aag lagne wali hai!"}

# --- 3. CRUD APIS ---

# CREATE: Naya task banana (Assignment Requirement: 2 second delay)
@app.post("/tasks", response_model=TaskResponse)
async def create_task(task: TaskCreate, db: Session = Depends(get_db)):
    await asyncio.sleep(2) # Ye raha 2-second ka artificial delay!
    db_task = database.TaskDB(**task.model_dump())
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    return db_task

# READ: Saare tasks dekhna (Saath mein Search aur Filter ka logic bhi daal diya)
@app.get("/tasks", response_model=List[TaskResponse])
def read_tasks(search: Optional[str] = None, status: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(database.TaskDB)
    if search: # Agar user ne search kiya hai
        query = query.filter(database.TaskDB.title.contains(search))
    if status: # Agar user ne filter lagaya hai
        query = query.filter(database.TaskDB.status == status)
    return query.all()

# UPDATE: Task ko edit karna (Assignment Requirement: 2 second delay)
@app.put("/tasks/{task_id}", response_model=TaskResponse)
async def update_task(task_id: int, task: TaskCreate, db: Session = Depends(get_db)):
    await asyncio.sleep(2) # Yahan bhi 2-second ka delay
    db_task = db.query(database.TaskDB).filter(database.TaskDB.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    for key, value in task.model_dump().items():
        setattr(db_task, key, value)
        
    db.commit()
    db.refresh(db_task)
    return db_task

# DELETE: Task ko delete karna
@app.delete("/tasks/{task_id}")
def delete_task(task_id: int, db: Session = Depends(get_db)):
    db_task = db.query(database.TaskDB).filter(database.TaskDB.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Task not found")
    db.delete(db_task)
    db.commit()
    return {"message": "Task deleted successfully"}