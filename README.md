# Taskify

## Project Title
Taskify - A To-Do List Application

## Video URL
[Video URL here]

# Description
Taskify is a simple and efficent  to-do list application designed to help users manage thier tasks effectively.The app allows users
to create , update and delete tasks, providing a streamlined
user experience.

### Features 

- **Add Tasks**: Quickly add tasks with sample and intuitive interface.
- **Edit Tasks**: Modify task details esily to keep your list up-to-date.

- **Delete Tasks**: Remove completed or unnecessary tasks with a signle click.

- **User Authentication**: scure login and regisration functionality to keep your tasks private.

### Technologies Used

- **Backend**:  Python with FastAPI
- **Frontend**: SwiftUI
- **Database**: SQlite


### How to Run the project:
1. **Backend**:
    - Navigate to the backend direcdtory:
        ```bash
        cd Taskify/backend
        ```
    - Set up a virtual environment and install dependencies:
    ```bash
    python3 -m venv env
    source env/bin/activate
    pip install -r requirements.txt # install all dependencies 
    ```
    - To Create backend database:
    ```bash
    python ini_db.py # this is run once to create the database with user and task  tables
    ```

    - Start the backend server:
    ```bash
    uvicorn main:app --reload # OR fastapi dev main.py
    ```


2. **FrontEnd**:
   - Open the `Taskify/frontend` directory in Xcode.
   - Build and run the project on a simulator or a physical device.

### How to Contribute
if you would like to contribute to Taskify, please fork the repository and submit a pull  request.I welcome all contribution.

# Contact 
For any questions or feedback, please contact me at: **Email**:nsambai72@gmail.com.
**Whatsap**:+256775186921

