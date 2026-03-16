import { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { useSocket } from '../socket/useSocket';
import { api } from '../services/api';

export function AuctionDetail() {
  const { id } = useParams();
  const [auction, setAuction] = useState<any>(null);
  const [bidAmount, setBidAmount] = useState('');
  const socket = useSocket();

  useEffect(() => {
    api.get(`/auctions/${id}`).then(res => setAuction(res.data));

    socket.emit('joinAuction', id);

    socket.on('newBid', (bid) => {
      setAuction(prev => ({ ...prev, currentBid: bid.amount }));
    });

    return () => {
      socket.emit('leaveAuction', id);
      socket.off('newBid');
    };
  }, [id, socket]);

  const placeBid = () => {
    socket.emit('placeBid', {
      auctionId: id,
      amount: parseFloat(bidAmount),
    });
  };

  if (!auction) return <div>Loading...</div>;

  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold">
        {auction.vehicle?.make} {auction.vehicle?.model}
      </h1>

      <p className="text-lg">
        Current Bid: ₦{auction.currentBid}
      </p>

      <input
        type="number"
        value={bidAmount}
        onChange={(e) => setBidAmount(e.target.value)}
        placeholder="Your bid"
        className="border p-2 mr-2"
      />

      <button
        onClick={placeBid}
        className="bg-blue-500 text-white px-4 py-2"
      >
        Place Bid
      </button>
    </div>
  );
}
