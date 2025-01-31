
<h1 align="center">Pilot Fatigue Management System DBMS</h1>

<p align="center">A database-first solution to pilot fatigue tracking and prevention.</p>

## Project Description

This repository contains the source code for a Pilot Fatigue Management System (PFMS). The system is designed as a database-first application, intended to track and manage pilot fatigue levels, providing real-time insights to enhance flight safety and operational efficiency. This system aims to assist airlines and aviation authorities in proactively addressing fatigue-related risks.

## Main Features

*   **User Authentication:** Secure login and signup for different user roles (pilots, operations, and admins) using Firebase Authentication.
*   **Fatigue Assessment:** Pilots can complete fatigue assessments before flights, providing data-driven insights into their well-being.
*   **Flight Management:** Operations personnel can manage flight details, assign pilots, and view fatigue assessment data.
*   **Admin Tools:**  Admin users can manage system configurations, monitor reports, and adjust fatigue scoring parameters.
*   **Risk Categorization:** Flights are automatically classified into risk categories (Healthy, Moderate, Critical) based on pilot assessments and fatigue factors.
*   **Cross-Platform Compatibility:** Built with Flutter, ensuring the system can run on Android, iOS, Linux, macOS, Web and Windows platforms.
*   **Firebase Integration:** Uses Firebase Firestore to store user and flight data for scalability and reliability.
*   **Real-time Data:** Real-time data updates for flight risk status, fatigue assessment scores, and pilot availability, leveraging Firebase.

## Installation and Setup

To set up and run this project, you will need Flutter and Firebase installed and configured.

1.  **Install Flutter:** If you haven't already, follow the instructions on the [Flutter website](https://flutter.dev/docs/get-started/install).
2.  **Install Firebase CLI:** Follow the instructions on the [Firebase website](https://firebase.google.com/docs/cli) to install and log in.
3.  **Create a Firebase Project:** Set up a new Firebase project in the Firebase console.
4.  **Enable Firebase Services:** Enable Firebase Authentication and Firebase Firestore.
5. **Download google-services.json:**
    Download the `google-services.json` configuration file from your Firebase console and place it in the `android/app/` directory.
6.  **Clone the Repository:** Use git clone to clone this repository to your local machine.

## Running the Project

1.  **Navigate to the Project Directory:**
    ```bash
    cd Pilot-Fatigue-Management-System-DBMS/src
    ```
2. **Install Dependencies:** Run the following command to fetch all the necessary Flutter packages.
    ```bash
    flutter pub get
    ```
3.  **Run the application:** Use the following command to run the project on your connected device or simulator:
    ```bash
     flutter run
    ```

    You can also specify a target platform with command, such as:
   ```bash
    flutter run -d chrome  # For web application
    ```
    
## Dependencies and Tools
*   **Flutter:** UI toolkit for building applications.
*   **Firebase Core:**  Core Firebase functionalities.
*   **Firebase Authentication:** User authentication management.
*   **Cloud Firestore:**  Scalable database for storing application data.
*   **Intl:** Provides support for internationalization in Flutter apps.

## Contribution Guide

We welcome contributions to the Pilot Fatigue Management System! To get started:

1.  **Fork the repository:** Create a fork of the main repository to work in your own space.
2.  **Create a new branch:** Make your changes in a new feature branch from the development branch.
3.  **Make your changes:** Implement your changes, adhering to the project's style and guidelines.
4.  **Commit your changes:**  Commit your changes with clear and concise messages.
5.  **Push your branch:** Push your changes to your fork.
6.  **Create a Pull Request:** Submit a pull request to the development branch of the main repository for review.

## License

This project is licensed under the MIT License

