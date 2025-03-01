# Direct Farmer-to-Consumer Marketplace

## Overview

The **Direct Farmer-to-Consumer Marketplace** is a mobile application built using **Flutter (Dart)** that enables farmers to sell their produce directly to consumers. The platform focuses on **vegetables and groceries with a longer shelf life**, ensuring efficient and sustainable transactions.

## Features

- Farmers can list their available produce for sale.
- Consumers can browse and purchase listed items.
- Only products with longer shelf life (e.g., cabbage, potato, rice, dry beans) are allowed.
- Orders are **prioritized** based on an optimized algorithm to ensure efficiency in delivery and logistics.
- Seamless order management and tracking.

## Order Prioritization Algorithm

The application follows a structured priority-based order handling system:

1. **Short-distance orders** are prioritized over long-distance orders.
2. Within short-distance orders:
   - **Small quantity orders** are prioritized over bulk orders.
3. Within long-distance orders:
   - **Bulk orders** are prioritized over small orders.
4. **Small orders from long distances (minimum 20km)** are considered but given the lowest priority.

## Technology Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase / Node.js (To be decided)
- **Database:** Firestore / PostgreSQL (To be decided)
- **Hosting:** Firebase / AWS (To be decided)

## Future Enhancements

- Implement an **adaptive distance threshold** based on demand and delivery conditions.
- Add a **rating system** for both farmers and consumers.
- Introduce an **express priority option** for urgent orders.
- Enable **batch processing** for small orders from the same region.
- Ensure **fair distribution** of orders among farmers.

## Getting Started

1. Clone the repository:
   ```sh
   git clone https://github.com/your-repo/direct-farmer-marketplace.git
   ```
2. Navigate to the project folder:
   ```sh
   cd direct-farmer-marketplace
   ```
3. Install dependencies:
   ```sh
   flutter pub get
   ```
4. Run the app:
   ```sh
   flutter run
   ```

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License.

---

Developed by** The Optimizers**

