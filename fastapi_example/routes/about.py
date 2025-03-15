from fastapi import APIRouter, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates

router = APIRouter()  # роутер для страницы "О приложении"
templates = Jinja2Templates(directory="templates")

@router.get("/about", response_class=HTMLResponse)
async def read_about(request: Request):
    """
    Обработчик страницы "О приложении". Возвращает информацию о приложении.
    """
    return templates.TemplateResponse(
        name="about.html", 
        context={"request": request}
    )
