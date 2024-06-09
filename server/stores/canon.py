import requests
from bs4 import BeautifulSoup

def canon(url: str):
    # Using a session object
    session = requests.Session()

    # Set a user-agent to mimic a web browser request
    headers = {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36',
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
            "availability": availability
        }
    else:
        print("Failed to retrieve the webpage, Status Code:", response.status_code)
        return None
