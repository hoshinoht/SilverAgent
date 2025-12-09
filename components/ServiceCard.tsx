import React from 'react';

interface ServiceCardProps {
  icon: React.ReactNode;
  label: string;
  onClick: () => void;
  colorClass?: string;
  isPromo?: boolean;
}

export const ServiceCard: React.FC<ServiceCardProps> = ({ icon, label, onClick, colorClass = "bg-white", isPromo }) => {
  return (
    <button 
      onClick={onClick}
      className="flex flex-col items-center justify-center gap-2 p-2 active:scale-95 transition-transform duration-100 group w-full"
    >
      <div className={`w-14 h-14 rounded-2xl ${colorClass} shadow-sm border border-slate-100 flex items-center justify-center text-slate-700 relative overflow-hidden group-hover:shadow-md transition-shadow`}>
        {isPromo && (
          <div className="absolute top-0 right-0 w-3 h-3 bg-red-500 rounded-full border-2 border-white translate-x-1 -translate-y-1"></div>
        )}
        <div className="transform group-hover:-translate-y-0.5 transition-transform duration-200">
          {icon}
        </div>
      </div>
      <span className="text-xs font-medium text-slate-700 text-center leading-tight">{label}</span>
    </button>
  );
};
