from fastapi import APIRouter, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates

router = APIRouter()  # создаём роутер для главной страницы

# Инициализируем движок шаблонов, указывая папку с HTML-шаблонами
templates = Jinja2Templates(directory="templates")

@router.get("/", response_class=HTMLResponse)
async def read_home(request: Request):
    """
    Обработчик главной страницы. Возвращает приветственное сообщение.
    """
    # Возвращаем HTML-шаблон "index.html", передавая в него объект Request (обязателен для шаблонов FastAPI)
    return templates.TemplateResponse(
        name="index.html", 
        context={"request": request}
    )
