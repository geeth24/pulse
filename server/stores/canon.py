from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from bs4 import BeautifulSoup
import time


def canon(url: str):
    chrome_options = Options()
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--disable-setuid-sandbox")
    chrome_options.add_argument(
        "--disable-software-rasterizer"
    )  # Avoid hardware acceleration issues
    chrome_options.add_argument("--disable-gpu")
    chrome_options.add_argument(
        "--window-size=1920,1080"
    )  # Set window size for non-headless mode

    # Use a fake user-agent to mimic a real browser
    chrome_options.add_argument(
        "user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    )

    # Connect to the remote Selenium Chrome instance
    driver = webdriver.Remote(
        command_executor="http://chrome:4444/wd/hub",
        options=chrome_options,
    )

    try:
        driver.get(url)
        time.sleep(5)  # Wait for the page to fully load

        # Parse page source with BeautifulSoup
        soup = BeautifulSoup(driver.page_source, "html.parser")

        # Extract product name
        product_name = (
            soup.find("span", {"data-ui-id": "page-title-wrapper"}).text.strip()
            if soup.find("span", {"data-ui-id": "page-title-wrapper"})
            else "Not found"
        )

        # Extract product price
        price_container = soup.find("span", {"data-price-type": "finalPrice"})
        price = (
            price_container.find("span", class_="price").text.strip()
            if price_container and price_container.find("span", class_="price")
            else "Not found"
        )

        # Check availability
        availability_tag = soup.find("div", text=lambda x: x and "In Stock" in x)
        availability = "In Stock" if availability_tag else "Out of Stock"

        # Return the product information
        return {
            "name": product_name,
            "price": price,
            "availability": availability,
            "url": url,
        }

    finally:
        driver.quit()
