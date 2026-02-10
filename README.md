# Personal Finance Tracker
### A Doodle Assessment Project

## Architecture

The project used Cubit (flutter_bloc) architecture.

High level architecture is as follows:
```text
+-------------------+         +--------------------------+         +---------------------+         +---------------------------+
|       UI          |         | Cubit (State Management) |         |     Repository      |         |        Data Source        |
| (Screens/Widgets) |  ---->  | (Business Logic + State) |  ---->  | (Data Abstraction)  |  ---->  | (SQLite / SharedPrefs)    |
+-------------------+         +--------------------------+         +---------------------+         +---------------------------+
         ^                                                                                                         |
         |                                                                                                         |
         +---------------------------------------- State Updates --------------------------------------------------+
```

#### The project is structured into three primary layers:
1. UI layer (lib/ui) - screen, widgets, and user interaction
2. State management layer (lib/bloc) - Cubits + States (business logic and UI state)
3. Data layer (lib/data) - Repository, Data Source (SQLite + Shared Preferences)

## UI Ideation

<img src="https://github.com/gautamsawala/personal_finance_tracker/blob/master/pft_home_page.png?raw=true" alt="Home Page" width="400"/>

<img src="https://github.com/gautamsawala/personal_finance_tracker/blob/master/pft_add_expense_income.png?raw=true" alt="Add Income/ Expense Modal" width="400"/>

## Trade-offs
- I prefer having Widget(onPressed()/onTap() -> onTop) followed by other parameters. It is not consistent in this project.
- The UI has been rendered on Pixel 7. It has not been tested for overflows for smaller screens.
- The text scaling of the phone might also cause overflow issues. The app was designed with system fonts at medium size.


## Improvements
Here is what I would improve given I had more time:
- Improve transaction filters. 
  - At the moment the filters don't work reliably and in tandem.
  - The start date of a filter must be restricted to date of first transaction.
- Better user feedback.
  - On a new transaction, the transaction that was added must be scrolled to and highlighted for a moment.
- Improve UI.
  - The way you enter the amount while adding transaction, there are modern way widget can be implemented.
  - The add transaction button is hard to reach, with single hand use. 
  - Floating add transaction button, that can be moved around the screen.
- Extended features.
  - Support for decimal separators based on locale.
  - Support for different currencies.
- Modularization and Standardize.
  - Modularize and improve reused functions `_money()` and `_parseAmountToCents()`.
  - Standardize function `DateFormat()` to be consistent across apps.


## Estimated time spent
About 6 hours.
