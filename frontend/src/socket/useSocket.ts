import { io } from 'socket.io-client';
import { useMemo } from 'react';

export const useSocket = () => {
  return useMemo(() => io(process.env.REACT_APP_API_URL || 'http://localhost:3000'), []);
};
