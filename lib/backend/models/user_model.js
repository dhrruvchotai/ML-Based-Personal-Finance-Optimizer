import mongoose from "mongoose";

const userSchema = new mongoose.Schema( 
    {
        userName : {
            type : String,
            required : true,
            trim : true,
        },
        email : {
            type : String,
            required : true,
            trim : true,
            unique : true,
        },
        password : {
            type : String,
        },
    },
    {
        timestamps : true,
    }
);

const Users = mongoose.model("Users",userSchema);
export default Users;