import React, { createContext, useContext, useState } from 'react';

interface WalletContextType {
  balance: number;
  refreshBalance: () => void;
}

const WalletContext = createContext<WalletContextType>(null!);

export const WalletProvider = ({ children }: { children: React.ReactNode }) => {
  const [balance, setBalance] = useState(0);
  const refreshBalance = async () => { /* fetch from API */ };
  return (
    <WalletContext.Provider value={{ balance, refreshBalance }}>
      {children}
    </WalletContext.Provider>
  );
};
export const useWallet = () => useContext(WalletContext);
