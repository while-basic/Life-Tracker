Prompt:

Scaffold an iOS application designed to manage aspects throughout life. As the user experiences life and events, this app will be the go-to application to record important information, life events, bills, and more.

---

### Navigation Tabs

- Home
    - **AI-Powered Snapshot:** At launch, a summary card appears with a "Generate" button with AI insights based off the users data.
        - Example: “You’re 10% off your monthly budget, next birthday in 12 days, workout streak: 5.

- Calendar
    1. Work schedule
        1. Hours worked
        2. Base pay earned
        3. Overtime earned
    2. Paydays
    3. Events
        1. Birthdays
        2. Important dates
        3. Anniversary
        4. General
        5. Studio session
        6. Meetings
        7. Medication
        8. Doctors appointments
    4. Gym schedule
        1. Detailed tracker with exercises
    5. View expenses due dates
        1. One-time
        2. Recurring

- Financial
    1. **Example: Predictive Analytics:** Based on past paychecks and expenses, forecast cash-flow 6 months out, highlight when you’ll hit savings goals or risk overdraft.
    2. **Example: Smart Alerts:** Not just reminders, but “Your phone bill just spiked—here’s how it’ll impact your June budget” or “You’ve consistently hit overtime—consider asking for a shift differential boost.”
    3. Track expenses
        1. One-time
        2. Recurring
    4. Add Goal Savings

- Quick Tools
    - Countdown Timer
        - Countdown in real time (updates every 1 seconds) to a particular event from the Calendar
    - Storybook
        - Integrated with "Calendar Journal" which allows the user to enter a short entry for the day, identifying events that happened.
        - LLM will "Generate Story" based off the calendar entries for every week, month, and year.
        - When a story has been generated, the user will recieve a notification with the newewst
    - Paycheck calculator
    - Goals Editor
    - Bucket list
    - Time remaining
        - Allows user to visualize how many days/weeks/months/years have passed and the amount of time remaining until the user reaches 100 years old. Inspired by (https://waitbutwhy.com/2015/12/the-tail-end.html). 

- Profile
    - Net worth
    - Total expenses
        - Total amount of money spent on expenses from start of app to current date
    - Total savings
        - Total amount of money saved to date
    - Goal progress
        - Lists all goals and their progress
    - Badges Earned
        - Achievements earned
        - “First Paycheck” unlocks a badge
        - “100 Days Workout Streak” badge
        - “Promotion achieved” badge
    
    ---
    
    
    Examples: 
    
    - Countdown timer will be integrated with Calendar
    - Goals editor will be tied in with goal progress
    - Expenses are visible in calendar view

Notes:

- OpenAI integration for AI features
    - Auto-detect Milestones from calendar and financial data
-     All features and tools available must be interconnected with each other.
- App should be minimalistic with a modern vibe
- Color coded for specific details
- Notifications enabled
    - Examples:
        - Congrats on 1 year anniversary—here’s your memory card!
        - Your moms birthday is this week. Have you bought a present?
        - Last weeks paycheck was larger than this week.
        - You have a scheduled trip to Alaska this month and will lose 5 days of work, which is (x) dollar amount and (x) work hours.


# POST APP INSPECTION
    - Countdown need a timer countdown for seconds,hours,days, weeks, months, and years, not just the date.

# STORYBOOK FEATURE
    - In the calendar view, allow the user to enter journal entries of their day.
    - After 7 days, the AI will generate a "life story" every week, month, and year.
        - Every week: The AI will review all journal entries for the week and generate a story that's relevant to the users data.
        - Every month: AI generates for the weeks.
        - Every year: AI generates everything for the year.
    - At the top of the storybook viewm indicate the following:
        - Entries
        - Words written
        - Days journaled
    - Create "Chapters", which are weeks in a year.
    - A "Book" is composed of 12 months or 52 weeks of journal entries as well the users data.

# MY LIFE
    - In the profile tab, create a new feature that allows the user to enter several countless details about themselves.
        - Name, DOB, Hobbies, Marital status, employment, hourly rate, total monthly gross income, vehicles owned, etc...
        - All details will be relevant to the user and their life.
    - This data will be later used by OpenAI to generate a "Storybook Chapter".
