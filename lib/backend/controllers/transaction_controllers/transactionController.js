import Transactions from "../../models/transactionModel.js";

export const addTransaction = async (req, res) => {
    const { userId, transactionDate, isExpense, amount, description, category } = req.body;

    try {
        const newTransaction = new Transactions({
            userId,
            transactionDate,
            isExpense,
            amount,
            description,
            category
        });

        const savedTransaction = await newTransaction.save();
        res.status(201).json(savedTransaction);
    }catch (error) {
        console.error("Error adding transaction:", error);
        res.status(500).json({ message: "Internal server error" });
    }
}

export const getTransactions = async (req, res) => {
    const { userId } = req.params;

    try{
        const transactions = await Transactions.find({ userId }).sort({ transactionDate: -1 });
        res.status(200).json(transactions);
    }catch (error) {
        console.error("Error fetching transactions:", error);
        res.status(500).json({ message: "Internal server error" });
    }
};

export const deleteTransaction = async (req, res) => {
    
    const { transactionId } = req.params;
    
    try {
        const deletedTransaction = await Transactions.findByIdAndDelete(transactionId);
        
        if (!deletedTransaction) {
            return res.status(404).json({ message: "Transaction not found" });
        }
        
        res.status(200).json({ message: "Transaction deleted successfully" });
    }
    catch (error) {
        console.error("Error deleting transaction:", error);
        res.status(500).json({ message: error.message || "Internal server error"});
    }
};
