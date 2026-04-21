<<<<<<< HEAD
from fastapi import FastAPI

# import all route files
from routes import (
    auth_routes,
    product_routes,
    sales_routes,
    dashboard_routes,
    ai_routes,
    forecast_routes
)

# create app
app = FastAPI()

# include routes
app.include_router(auth_routes.router, prefix="/auth")
app.include_router(product_routes.router, prefix="/product")
app.include_router(sales_routes.router, prefix="/sales")
app.include_router(dashboard_routes.router, prefix="/dashboard")
app.include_router(ai_routes.router, prefix="/ai")
app.include_router(forecast_routes.router)  # no prefix

# root test
@app.get("/")
def root():
    return {"message": "EZ System API Running"}
=======
>>>>>>> 2b11b5c212a31e8bcaabfdbdd2dc9714091abd9e
