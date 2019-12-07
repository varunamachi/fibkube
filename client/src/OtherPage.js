import React from 'react';
import { Link } from 'react-router-dom';

export default () => {
    return (
        <div>
            Hi! You have reached the other side!
            <br></br>
            <Link to="/">Back to home</Link>
        </div>
    );
};