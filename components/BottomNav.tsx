import React from 'react';
import { Home, Compass, Wallet, User, Plus } from 'lucide-react';

interface BottomNavProps {
  onFabClick: () => void;
  activeTab: string;
  onTabChange: (tab: string) => void;
}

export const BottomNav: React.FC<BottomNavProps> = ({ onFabClick, activeTab, onTabChange }) => {
  const navItems = [
    { id: 'home', label: 'Home', icon: Home },
    { id: 'activity', label: 'Activity', icon: Compass },
    { id: 'pay', label: 'Pay', icon: Wallet },
    { id: 'account', label: 'Account', icon: User },
  ];

  return (
    <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-slate-100 px-6 py-3 pb-6 flex justify-between items-center z-40 max-w-md mx-auto">
      {navItems.map((item, index) => {
        // Insert FAB in the middle (index 2)
        if (index === 2) {
          return (
            <React.Fragment key="fab">
              <div className="relative -top-5">
                <button 
                  onClick={onFabClick}
                  className="group flex items-center justify-center w-14 h-14 rounded-full bg-slate-900 text-white shadow-lg shadow-slate-900/20 hover:scale-105 active:scale-95 transition-all border-[4px] border-slate-50"
                  aria-label="New Task"
                >
                  <div className="absolute inset-0 bg-primary rounded-full opacity-0 group-hover:opacity-20 transition-opacity" />
                  <Plus size={28} strokeWidth={2.5} />
                </button>
              </div>
              <button 
                key={item.id}
                onClick={() => onTabChange(item.id)}
                className={`flex flex-col items-center gap-1 transition-colors ${
                  activeTab === item.id ? 'text-primary' : 'text-slate-400 hover:text-slate-600'
                }`}
              >
                <item.icon size={24} strokeWidth={activeTab === item.id ? 2.5 : 2} />
                <span className={`text-[10px] ${activeTab === item.id ? 'font-bold' : 'font-medium'}`}>
                  {item.label}
                </span>
              </button>
            </React.Fragment>
          );
        }

        return (
          <button 
            key={item.id}
            onClick={() => onTabChange(item.id)}
            className={`flex flex-col items-center gap-1 transition-colors ${
              activeTab === item.id ? 'text-primary' : 'text-slate-400 hover:text-slate-600'
            }`}
          >
            <item.icon size={24} strokeWidth={activeTab === item.id ? 2.5 : 2} />
            <span className={`text-[10px] ${activeTab === item.id ? 'font-bold' : 'font-medium'}`}>
              {item.label}
            </span>
          </button>
        );
      })}
    </div>
  );
};