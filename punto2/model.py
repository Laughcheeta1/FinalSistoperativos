from pydantic import BaseModel

class User(BaseModel):
    nombre: str
    edad: int
    altura: float