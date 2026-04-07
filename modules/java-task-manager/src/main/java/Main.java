package main.java;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

class Task {
    private final String id;
    private final String title;
    private boolean completed;

    Task(String title) {
        this.id = UUID.randomUUID().toString();
        this.title = title;
        this.completed = false;
    }

    String getId() {
        return id;
    }

    String getTitle() {
        return title;
    }

    boolean isCompleted() {
        return completed;
    }

    void toggleCompleted() {
        this.completed = !this.completed;
    }
}

class TaskManager {
    private final List<Task> tasks = new ArrayList<>();

    public Task addTask(String title) {
        Task task = new Task(title);
        tasks.add(task);
        return task;
    }

    public List<Task> getTasks() {
        return tasks;
    }

    public boolean toggleTask(String taskId) {
        for (Task task : tasks) {
            if (task.getId().equals(taskId)) {
                task.toggleCompleted();
                return true;
            }
        }
        return false;
    }

    public boolean deleteTask(String taskId) {
        return tasks.removeIf(task -> task.getId().equals(taskId));
    }
}

public class Main {

    public static void main(String[] args) {
        TaskManager manager = new TaskManager();

        Task firstTask = manager.addTask("Estudiar para examen");
        manager.addTask("Terminar practica");

        manager.toggleTask(firstTask.getId());

        for (Task task : manager.getTasks()) {
            System.out.println(task.getTitle() + " | completada=" + task.isCompleted());
        }
    }
}
