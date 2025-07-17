import Users from "../../models/user_model.js";

// Add a new user
export const addUser = async(req, res) => {
    try {
        const { userName, email, password } = req.body;

        console.log(req.body);

        if (userName === "" || email === "" || password === "") {
            return res.status(400).json({ message: "All fields are required" });
        }

        const userExists = await Users.findOne({ email });
        if (userExists) {
            return res.status(400).json({ message: "User already exists" });
        }
        const user = new Users({ userName, email, password });
        await user.save();
        res.status(201).json({ message: "User created successfully", user });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get all users
export const getAllUsers = async(req, res) => {
    try {
        const users = await Users.find({}, "-password"); // Exclude password
        res.status(200).json(users);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Delete a specific user by ID
export const deleteUser = async(req, res) => {
    try {
        const { id } = req.params;
        const user = await Users.findByIdAndDelete(id);
        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }
        res.status(200).json({ message: "User deleted successfully" });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};