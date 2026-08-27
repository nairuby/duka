# Tailwind CSS Setup & Customization

This document explains how Tailwind CSS is set up and customized in this Rails project.

---

## 1. Installation & Dependencies

- Tailwind CSS is installed and configured for use with Rails.
- The main configuration file is at `config/tailwind.config.js`.
- The main Tailwind stylesheet is at `app/assets/stylesheets/application.tailwind.css`.

---

## 2. Configuration

### `config/tailwind.config.js`
- **Content paths**: Tailwind scans HTML, ERB, HAML, SLIM, JS, and Ruby helper files for class names.
- **Theme customizations**:
  - **Fonts**: Adds `Inter var`, `Courier Prime`, and `Geist` to the font family options.
  - **Colors**: Adds custom colors: `primary` (red-600), `secondary` (green-800), `accent` (blue-600), and `neutral` (gray-400).
- **Plugins**: Includes `@tailwindcss/forms`, `@tailwindcss/typography`, and `@tailwindcss/container-queries`.

---

## 3. Stylesheet Usage

### `app/assets/stylesheets/application.tailwind.css`

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

- You can add custom component styles using `@layer components`.
- Example (commented in the file):
  ```css
  @layer components {
    .btn-primary {
      @apply py-2 px-4 bg-blue-200;
    }
  }
  ```

---

## 4. Development Workflow

- **Do NOT run `bin/rails assets:precompile` in development.**
- If you accidentally precompile, run `bin/rails assets:clobber` and restart your Rails server.
- Tailwind will rebuild styles automatically on file changes in development.

---

## 5. Customization

- To add or change colors, fonts, or plugins, edit `config/tailwind.config.js`.
- To add custom CSS, use `@layer` in `application.tailwind.css`.

---

## 6. Troubleshooting

- If styles do not update, ensure you have not precompiled assets in development.
- Restart your Rails server after running `assets:clobber`.
- Check that your views use Tailwind classes and that the stylesheet is included in your layout.

---

## 7. References

- [Tailwind CSS Documentation](https://tailwindcss.com/docs/configuration)
- [Rails + Tailwind Guide](https://tailwindcss.com/docs/guides/ruby-on-rails) 