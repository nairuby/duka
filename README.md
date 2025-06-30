# Duka – Nairuby Community Shop 🛍️

A Ruby on Rails–powered e-commerce app offering official merchandise for the **African Ruby Community**, active since 2010 with over 4,000 members across East Africa.

> Visit the live store: [https://duka.nairuby.org](https://duka.nairuby.org)

---

## 🌟 Features

- 🛒 Shop mugs, t-shirts, and community gear
- 💳 Multi-currency support (KES & USD)
- 🔐 Secure checkout (Stripe/PayPal-ready)
- 🛠 Admin panel for managing inventory
- 📨 Order confirmation emails
- 🔍 Clean, accessible UI with responsive design

---

## 🚀 Built With

- **Ruby on Rails**
- **PostgreSQL**
- **Tailwindcss**
- **Hotwire / Turbo / Stimulus**
- **Stripe or Paystack**

---

## 📦 Installation

### Requirements

- Ruby >= 3.3.6
- Rails >= 8.0.2
- Node.js + Yarn
- PostgreSQL (or SQLite for dev)

### Setup Instructions

Clone the repo:

  ```bash
  git clone https://github.com/your-org/duka.git
  cd duka
  ```
Install dependencies:
 ```
  bundle install
  ```
Set up the database:
 ```
  rails db:setup
  ```
  or
  ```
  rails db:create
  rails db:migrate
  rails db:seed
  ```
Start the Rails server:
  ```
  bin/dev
  ```

Visit [http://localhost:3000](http://localhost:3000) in your browser.

## 🧪 Testing
Run test suite:
  ```
  bundle exec rspec
  ```

Lint Ruby code:
  ```
  bundle exec rubocop
  ```

Docker (optional)
  ```
  docker-compose build
  docker-compose up
  ```

Customize docker-compose.yml and Dockerfile as needed.

📸 Screenshots
(Add screenshots of the homepage, product page, cart, and admin dashboard here)

## 🤝 Contributing
We welcome contributions from the community! Please follow these steps:

Fork the repository

Create your feature branch: git checkout -b feature/amazing-feature

Commit your changes: git commit -m 'Add amazing feature'

Push to the branch: git push origin feature/amazing-feature

Open a Pull Request

See CONTRIBUTING.md for more info.

## 🌍 About the Project
Duka supports the African Ruby Community, promoting open source and software craftsmanship in East Africa since 2010. This shop helps fund meetups, workshops, and swag for the community.

## 📄 License
Distributed under the MIT License. See LICENSE for details.

