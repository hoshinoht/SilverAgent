import React from 'react';
import { TaskQueue } from './TaskQueue';
import { Task } from '../types';

interface ActivityViewProps {
  tasks: Task[];
  onTaskClick: (task: Task) => void;
}

export const ActivityView: React.FC<ActivityViewProps> = ({ tasks, onTaskClick }) => {
  return (
    <div className="p-5 pb-24 animate-in fade-in duration-300">
      <h2 className="text-2xl font-bold text-slate-800 mb-6 pt-2">Activity</h2>
      
      <div className="mb-6">
        <div className="bg-white p-4 rounded-xl shadow-sm border border-slate-100 flex justify-between items-center mb-6">
           <div>
              <p className="text-xs text-slate-500 font-bold uppercase tracking-wide">Tasks Completed</p>
              <p className="text-2xl font-bold text-slate-800 mt-1">{tasks.filter(t => t.status === 'COMPLETED').length}</p>
           </div>
           <div className="h-10 w-[1px] bg-slate-100"></div>
           <div className="text-right">
              <p className="text-xs text-slate-500 font-bold uppercase tracking-wide">Total Spent</p>
              <p className="text-2xl font-bold text-primary mt-1">S$ 342.50</p>
           </div>
        </div>
        
        <h3 className="text-sm font-bold text-slate-400 uppercase tracking-wider mb-3">Task History</h3>
        <TaskQueue tasks={tasks} onTaskClick={onTaskClick} />
      </div>
    </div>
  );
};