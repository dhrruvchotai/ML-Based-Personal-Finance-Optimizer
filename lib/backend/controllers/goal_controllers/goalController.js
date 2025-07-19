import Goal from "../../models/goalModel.js";

// Get all goals for a user
export const getGoals = async (req, res) => {
  try {
    const goals = await Goal.find({ userId: req.params.userId });
    res.status(200).json(goals);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Add a new goal
export const addGoal = async (req, res) => {
  try {
    const {
      userId,
      title,
      targetAmount,
      currentAmount,
      startDate,
      endDate,
      description,
    } = req.body;

    if (!userId || !title || !targetAmount || !startDate || !endDate) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    const goal = new Goal({
      userId,
      title,
      targetAmount,
      currentAmount: currentAmount || 0,
      startDate,
      endDate,
      description,
    });

    await goal.save();
    res.status(201).json(goal);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Delete a goal by ID
export const deleteGoal = async (req, res) => {
  try {
    const { goalId } = req.params;
    const deletedGoal = await Goal.findByIdAndDelete(goalId);
    if (!deletedGoal) {
      return res.status(404).json({ message: "Goal not found" });
    }
    res.status(200).json({ message: "Goal deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};