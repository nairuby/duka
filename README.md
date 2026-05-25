# ARC Duka – African Ruby Community Shop 🛍️

A modern Ruby on Rails e-commerce platform offering official merchandise for the **African Ruby Community (ARC)**, active since 2010 with over 4,000 members across East Africa.

> **Live Store:** [https://duka.nairuby.org](https://duka.nairuby.org)

---

## 🌟 Features

### Customer Features
- 🛒 Browse products by category (Shirts, Hoodies, Mugs, Accessories, etc.)
- 🎨 Product variants (sizes, colors) with stock tracking
- 🛍️ Real-time shopping cart with instant updates
- 💳 Multiple payment methods (Card, Bank Transfer, Cash on Delivery)
- 📱 Fully responsive mobile-first design
- 🔐 Secure checkout with guest and authenticated options
- 📧 Order confirmation and tracking
- 💱 Multi-currency support (KES, USD, EUR, GBP)

### Admin Features
- 🎛️ Beautiful admin panel powered by Avo
- 📊 Stock management dashboard with low stock alerts
- 📦 Product and variant management
- 🛒 Order management and tracking
- 👥 User management with role-based access
- 📈 Sales and inventory metrics

---

## 🚀 Tech Stack

- **Framework:** Ruby on Rails 8.1
- **Database:** PostgreSQL
- **Styling:** Tailwind CSS 4.0
- **JavaScript:** Hotwire (Turbo + Stimulus)
- **Admin Panel:** Avo 3.0
- **Authentication:** Devise
- **Payment Ready:** Stripe, Paystack integration points
- **Deployment:** Kamal 2.0

---

## 📦 Quick Start

### Prerequisites

- Ruby 3.4.7+
- Rails 8.1+
- PostgreSQL 14+
- Node.js 18+
- Yarn or npm

### Option 1: Local Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/nairuby/duka.git
   cd duka
   ```

2. **Install dependencies**
   ```bash
   bundle install
   yarn install  # or npm install
   ```

3. **Setup database**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

4. **Start the development server**
   ```bash
   bin/dev
   ```

5. **Visit the application**
   - Store: http://localhost:3000
   - Admin Panel: http://localhost:3000/avo
   - Admin Login: `admin@duka.com` / `admin123456`

### Option 2: Dev Container (Recommended)

This project includes a complete Dev Container setup for consistent development environments.

**Requirements:**
- Docker Desktop
- VS Code with Dev Containers extension

**Steps:**
1. Clone the repository
2. Open in VS Code
3. Click "Reopen in Container" when prompted
4. Run `rails db:setup` in the terminal
5. Run `bin/dev` to start the server

---

## 📚 Documentation

Comprehensive documentation is available in the `/docs` directory:

- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to contribute to the project
- **[docs/ADMIN_PANEL.md](docs/ADMIN_PANEL.md)** - Admin panel guide
- **[docs/CHECKOUT_SYSTEM.md](docs/CHECKOUT_SYSTEM.md)** - Checkout architecture
- **[docs/PRODUCT_VARIANTS.md](docs/PRODUCT_VARIANTS.md)** - Product & variant management
- **[docs/LOGIN_UI_FEATURES.md](docs/LOGIN_UI_FEATURES.md)** - Authentication UI details
- **[docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)** - Development guide (NEW)
- **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** - System architecture (NEW)

---

## 🧪 Testing

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/product_spec.rb

# Run with coverage
COVERAGE=true bundle exec rspec

# Lint Ruby code
bundle exec rubocop

# Auto-fix linting issues
bundle exec rubocop -a
```

---

## 🎨 Code Style

This project follows:
- **Ruby Style Guide** via RuboCop
- **Rails Best Practices**
- **Tailwind CSS** for styling
- **Stimulus** for JavaScript interactions

---

## 🗂️ Project Structure

```
duka/
├── app/
│   ├── avo/              # Admin panel resources
│   ├── controllers/      # Request handlers
│   ├── models/           # Business logic
│   ├── services/         # Service objects (CartService, etc.)
│   ├── views/            # Templates
│   └── javascript/       # Stimulus controllers
├── config/               # Configuration
├── db/                   # Database migrations & seeds
├── docs/                 # Documentation
├── spec/                 # Tests
└── public/               # Static assets
```

---

## 🤝 Contributing

We welcome contributions! Here's how to get started:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Make your changes**
   - Write tests for new features
   - Follow the code style guide
   - Update documentation as needed
4. **Commit your changes**
   ```bash
   git commit -m 'Add amazing feature'
   ```
5. **Push to your fork**
   ```bash
   git push origin feature/amazing-feature
   ```
6. **Open a Pull Request**

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

## 🔑 Configuration (Rails Credentials)

This project uses **Rails encrypted credentials** for sensitive configuration (including Quikk API keys), not plain `.env` secrets.

### Edit development credentials

```bash
EDITOR="code --wait" rails credentials:edit --environment development
```

Add:

```yml
quikk:
  api_key: your_quikk_api_key
  api_secret: your_quikk_api_secret
  shortcode: "174379"
```

### Edit production credentials

```bash
EDITOR="code --wait" rails credentials:edit --environment production
```

Add the same `quikk` keys for production values.

### Notes

- Keep `config/master.key` private and never commit it.
- `config/credentials/*.yml.enc` files are safe to commit.
- Non-sensitive local settings (if any) can still go in `.env`.

---

## 🚢 Deployment

This project uses Kamal 2.0 for deployment:

```bash
# Setup deployment
kamal setup

# Deploy
kamal deploy

# Check status
kamal app logs
```

See deployment documentation for detailed instructions.

---

## 📊 Key Features Explained

### Cart System
- Session-based cart (no login required)
- Real-time updates with Turbo Streams
- Optimistic UI for instant feedback
- Stock validation before checkout

### Checkout Flow
1. Add items to cart
2. Enter shipping information
3. Select payment method (Card, Bank Transfer, COD)
4. Confirm order
5. Receive confirmation email

### Admin Panel
- Powered by Avo for beautiful UI
- Manage products, variants, and stock
- View and process orders
- User management with admin roles
- Dashboard with key metrics

---

## 🌍 About the African Ruby Community

ARC Duka supports the African Ruby Community, promoting open source and software craftsmanship in East Africa since 2010. Revenue from this shop helps fund:

- Monthly meetups and workshops
- Community swag and merchandise
- Conference sponsorships
- Educational initiatives

---

## 📄 License

Distributed under the MIT License. See [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgments

- African Ruby Community members
- All contributors to this project
- Open source libraries and tools used

---

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/nairuby/duka/issues)
- **Discussions:** [GitHub Discussions](https://github.com/nairuby/duka/discussions)
- **Community:** [African Ruby Community](https://rubycommunity.africa/)
- **Email:** organisers@rubyconf.africa

---

**Made with ❤️ by the African Ruby Community**
