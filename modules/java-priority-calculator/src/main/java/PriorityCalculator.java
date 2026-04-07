package main.java;

public class PriorityCalculator {
    public static double calculateScore(int urgency, int difficulty, int hoursLeft) {
        int safeHours = Math.max(hoursLeft, 1);
        return (urgency * 0.5) + (difficulty * 0.3) + ((10.0 / safeHours) * 0.2);
    }

    public static String toPriorityLabel(double score) {
        if (score >= 8) {
            return "ALTA";
        }
        if (score >= 5) {
            return "MEDIA";
        }
        return "BAJA";
    }

    public static String calculate(String taskName, int urgency, int difficulty, int hoursLeft) {
        double score = calculateScore(urgency, difficulty, hoursLeft);
        return toPriorityLabel(score);
    }
}
