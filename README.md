# SpotSavor 🍴

Welcome to SpotSavor, where tradition meets innovation. Revolutionize how your restaurant handles reservations with our cutting-edge platform designed to streamline your workflow and enhance your guest experience. Say goodbye to paper logs and hello to seamless digital management—create, edit, update, and delete reservations with just a few clicks.

Empower your team with real-time updates and intuitive controls, making hosting and reservation management more efficient than ever. Whether you're booking a table for two or a party of twenty, SpotSavor ensures that every reservation is handled with precision and ease. Elevate your restaurant's operations and delight your guests with effortless reservation management. Embrace the future of dining with SpotSavor, where efficiency meets excellence.

<p align="center">
  <a href="#features">Check out the features!</a>
</p>
<p align="center">
<img width="500" alt="Screenshot 2024-09-06 at 3 32 43 PM" src="https://github.com/user-attachments/assets/b4d65b0f-f928-49f5-93c0-d732a6b230dc">
</p>

### Future Enhancements 🚀
### 1. User and Restaurant Management 👥🍽️
- **User Profiles**: Implement user accounts to enable personalized experiences.
- **Restaurant Profiles**: Allow restaurants to manage their own profiles with customizable settings.

### 2. Customizable Table Capacity and Scheduling 📅🛋️
- **Table Management**: Enable restaurants to customize their table capacities.
- **Start Times and Open Dates**: Provide options for restaurants to set start times and manage open dates.

  

### 3. Enhanced Analytics 📊📈
- **Advanced Metrics**: Introduce more comprehensive analytics tools to help restaurants track performance.
- **Growth Insights**: Provide actionable insights to assist restaurants in growing their business.

I’ve already made a start by implementing a few key metrics in the dashboard, and I'm excited to build upon this foundation to deliver even more value!

### Challenges Encountered 🚧

Throughout the development process, I encountered several challenges. The most significant of these was working with the `DateTime` type and configuring timezones within the application. Here are the key issues and how they impacted the development:

### 1. DateTime and Timezone Configuration ⏰

**Issue:** Handling the `DateTime` type and configuring timezones proved to be quite challenging. 

- **Unexpected Validation Errors:** I faced errors related to validations that were thrown unexpectedly. These errors were often linked to discrepancies between timezones, which caused issues with date and time comparisons and validations.

- **Timezone Consistency:** Ensuring that the application handled timezones consistently across different components was another major hurdle. Inconsistent timezone settings led to incorrect timestamps and validation failures.

**Resolution:** To address these challenges, I:
- **Standardized Timezones:** Configured the application to use a consistent timezone across all environments.
- **Refined Validations:** Updated validation logic to account for timezone differences and ensure accurate date and time handling.

Despite these efforts, working with `DateTime` and timezone configuration remains a complex aspect of the application, and further refinements may be needed.

If you have any insights or suggestions on handling these issues, I’d love to hear them!

## Getting Started
- Ruby (version >= 3.2.2)
- Rails (version >= 7.1.3.2)
- PostgreSQL
### Installation
1. `git clone`
2. `bundle install`
3. `rails db:{create, migrate, seed}`
### Usage
Start the server with:
`rails server`
### Testing
1. Run RSpec Tests 🏃‍♂️ Execute the RSpec tests with the following command: `bundle exec rspec`
2. Check Test Coverage 📊 We use SimpleCov to measure test coverage. After running the tests, SimpleCov will generate a coverage report, typically located in the coverage directory. Open coverage/index.html in your browser to view the detailed coverage report.
3. Verify Test Results ✅ You should see a total of 43 passing tests. Ensure that all tests pass to confirm that the application is functioning as expected.
4. Note on Dashboard Tests ⚠️ Please be aware that tests for the dashboard are still in progress, as they were part of a stretch goal. Some functionalities related to the dashboard may not yet be fully tested.

## Database Schema
```
create_table "reservations", force: :cascade do |t|
    t.string "name"
    t.integer "party_count"
    t.datetime "start_time"
    t.bigint "table_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["table_id"], name: "index_reservations_on_table_id"
  end

  create_table "tables", force: :cascade do |t|
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "reservations", "tables"
end
```


# <p align="center">Features</p>

<details>
  <summary style="font-size: 36 px; font-weight: bold;">Create a Reservation 📅</summary>
<p align="center">
  <img width="500" alt="Screenshot 2024-09-06 at 3 35 56 PM" src="https://github.com/user-attachments/assets/ffce80ff-7443-4b99-a7b0-a5f2f4b83243">
</p>

  The "Create a Reservation" feature allows users to book a reservation at any time, 24/7. Below is a detailed overview of how the feature works and the validations in place.

### Key Features

- **24/7 Booking**: Users can make reservations at any time, provided that certain conditions are met.
- **Real-Time Availability Check**: Reservations can be made as long as:
  - There is no existing reservation for the same time slot.
  - The reservation start time is in the past.
  - The party size does not exceed the table’s capacity.

### Form Requirements

To ensure a valid reservation, all fields in the form are required. If any field is left blank, users will receive a notification within the form indicating that the field is required. The fields typically include:

1. **Name**: The name of the person making the reservation.
2. **Date and Time**: The desired date and time for the reservation.
3. **Party Size**: The number of people in the party.

### Validation Rules

- **Existing Reservation Check**: The system checks for existing reservations for the specified date and time. Users will be informed if the chosen slot is already booked.
- **Past Date/Time Validation**: Reservations cannot be made for dates and times that have already passed or for times less than the current time.
- **Table Capacity Check**: The system verifies that the party size does not exceed the table's capacity. Users will receive an error if the party size is too large.
<p align="center">
  <img width="500" alt="Screenshot 2024-09-06 at 3 36 40 PM" src="https://github.com/user-attachments/assets/84135059-4380-4d1d-bd32-fd5768a9627e">
</p>

### Error Handling

- **Field Validation**: If any required field is not filled out, the form will display a notification indicating that the field is required.
- **Time and Capacity Errors**: Users will receive specific error messages if their reservation request fails due to existing reservations, past date/times, or exceeding table capacity.
<p align="center">
  <img width="500" alt="Screenshot 2024-09-06 at 3 37 29 PM" src="https://github.com/user-attachments/assets/3aceb4aa-a52f-4c15-b629-22b1d729d05b">
</p>

</details>

<details>
<summary> Reservations Index Page 📋</summary>
  <p align="center">
    <img width="500" alt="Screenshot 2024-09-06 at 3 35 31 PM" src="https://github.com/user-attachments/assets/f3ed68a5-cf0e-40e8-8471-524195bd90f9">
  </p>

The Reservations Index Page provides an overview of all reservations and offers various functionalities for managing them. Here’s a detailed description of the page features and interactions:

### Page Layout and Features

1. **Reservations List** 🗒️
   - **All Reservations Displayed**: The page lists all reservations with their relevant attributes, such as name, date, time, and party size.
   - **Sorted by Create Date**: Reservations are sorted from the earliest create date to the oldest create date, ensuring a chronological view of reservations.

2. **Reservation Details and Navigation** 🔗
   - **Reservation Name Link**: Each reservation entry displays the name of the person who made the reservation. This name is a clickable link that directs users to the reservation’s show page, where they can view more detailed information.

3. **Action Icons** ✏️🗑️
   - **Edit Icon**: On the right side of each reservation, there is an edit icon that allows users to modify the reservation details.
   - **Delete Icon**: Next to the edit icon is a trash icon. Clicking this icon activates a confirmation modal asking users to confirm the deletion of the reservation.

4. **Delete Confirmation Modal** ⚠️
   - **Confirmation Prompt**: When the delete icon is clicked, a modal window appears, prompting the user to confirm their intention to delete the reservation. This helps prevent accidental deletions.
  
<p align="center">
  <img width="500" alt="Screenshot 2024-09-06 at 3 37 52 PM" src="https://github.com/user-attachments/assets/7da0cf23-2dd9-4e4d-b3f7-a41d37ca3892">
</p>

5. **Total Reservations** 📊
   - **Count Display**: The total number of reservations is displayed at the top or bottom of the page, providing users with an overview of the current reservation volume.

6. **Call-to-Action** ✨
   - **Create Reservation Button**: A prominent call-to-action button is available on the page, encouraging users to create a new reservation. This button is typically located at the top or bottom of the page for easy access.

</details>

<details>
  <summary>SpotSavor Insights (IN PROGRESS)</summary>

  ## SpotSavor Dashboard Insights ✨
  <p align="center">
    <img width="500" alt="Screenshot 2024-09-08 at 3 52 24 PM" src="https://github.com/user-attachments/assets/5a4c5053-8197-4b79-b261-4b146e94af26">
  </p>

### 📅 Top 5 Upcoming Reservations
Easily view the top 5 upcoming reservations! 🎉 The list shows reservations scheduled for the future, helping you stay prepared for incoming guests.

### 📊 Weekend Watchout
Get insights into weekend reservations! 🗓️ This feature shows the percentage of reservations happening on Fridays, Saturdays, and Sundays, so you can manage weekend traffic better.

### ⏰ Reservation Rush (In Progress)
Identify the two most popular reservation times! 📈 This feature will help you understand peak dining hours and optimize staffing and resources accordingly.

---
<p align="center">
    <img width="200" alt="Screenshot 2024-09-06 at 5 52 59 PM" src="https://github.com/user-attachments/assets/11038694-4f76-49c3-b326-3f5e5314fc8c">
  
Stay tuned for more updates and enhancements! 🚀
</details>

