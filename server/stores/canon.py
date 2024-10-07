import requests
from bs4 import BeautifulSoup
import random

def canon(url: str):
    # Using a session object
    session = requests.Session()

    # Set a user-agent to mimic a web browser request
    user_agents = [
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3',
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36'
    ]

    headers = {
        'User-Agent': random.choice(user_agents),
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Referer': 'https://www.google.com/'
    }

    # Make the request with headers
    response = session.get(url, headers=headers)

    # Check if the request was successful
    if response.status_code == 200:
        # Parse the HTML content
        soup = BeautifulSoup(response.text, 'html.parser')

        # Extracting product details
        product_name = soup.find('span', class_='base').text.strip() if soup.find('span', class_='base') else "Not found"
        price = soup.find('span', class_='price').text.strip() if soup.find('span', class_='price') else "Not found"

        # Check if the product is in stock
        availability_tag = soup.find('div', text=lambda x: x and "In Stock" in x)
        availability = "In Stock" if availability_tag else "Out of Stock"

        return {
            "name": product_name,
            "price": price,
            "availability": availability,
            "url": url
        }
    else:
        print("Failed to retrieve the webpage, Status Code:", response.status_code)
        return None
