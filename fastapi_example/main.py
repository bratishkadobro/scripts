from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
import uvicorn

# Импортируем маршруты из routes
from routes import home, about

app = FastAPI(title="FastAPI Test App")

app.mount("/static", StaticFiles(directory="static"), name="static")

app.include_router(home.router)
app.include_router(about.router)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)
