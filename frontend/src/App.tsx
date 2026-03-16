import { Routes, Route } from 'react-router-dom';
import { Login } from './pages/Login';
import { Register } from './pages/Register';
import { Dashboard } from './pages/Dashboard';
import { AuctionDetail } from './pages/AuctionDetail';
import { Wallet } from './pages/Wallet';

function App() {
  return (
    <Routes>
      <Route path=\"/login\" element={<Login />} />
      <Route path=\"/register\" element={<Register />} />
      <Route path=\"/dashboard\" element={<Dashboard />} />
      <Route path=\"/auction/:id\" element={<AuctionDetail />} />
      <Route path=\"/wallet\" element={<Wallet />} />
    </Routes>
  );
}
export default App;
