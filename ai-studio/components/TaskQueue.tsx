import React from 'react';
import { Task, TaskStatus, ServiceType } from '../types';
import { Car, Utensils, ShoppingBag, Stethoscope, Zap, Clock, CheckCircle2, Loader2 } from 'lucide-react';

interface TaskQueueProps {
  tasks: Task[];
  onTaskClick: (task: Task) => void;
}

const getServiceIcon = (type: ServiceType) => {
  switch (type) {
    case ServiceType.TRANSPORT: return <Car size={18} className="text-white" />;
    case ServiceType.FOOD: return <Utensils size={18} className="text-white" />;
    case ServiceType.MART: return <ShoppingBag size={18} className="text-white" />;
    case ServiceType.HEALTH: return <Stethoscope size={18} className="text-white" />;
    default: return <Zap size={18} className="text-white" />;
  }
};

const getStatusColor = (status: TaskStatus) => {
  switch (status) {
    case TaskStatus.PENDING: return 'bg-yellow-500';
    case TaskStatus.IN_PROGRESS: return 'bg-primary';
    case TaskStatus.COMPLETED: return 'bg-slate-600';
    case TaskStatus.FAILED: return 'bg-red-500';
    default: return 'bg-slate-400';
  }
};

export const TaskQueue: React.FC<TaskQueueProps> = ({ tasks, onTaskClick }) => {
  if (tasks.length === 0) {
    return (
      <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 text-center">
        <div className="inline-flex items-center justify-center w-12 h-12 rounded-full bg-slate-50 mb-3 text-slate-400">
          <Zap size={24} />
        </div>
        <p className="text-sm text-slate-500 font-medium">No active tasks</p>
        <p className="text-xs text-slate-400 mt-1">Ask MCP to start automating</p>
      </div>
    );
  }

  // Show only active or recently completed tasks
  const activeTasks = [...tasks].reverse().slice(0, 3);

  return (
    <div className="space-y-3">
      {activeTasks.map((task) => (
        <div 
          key={task.id} 
          onClick={() => onTaskClick(task)}
          className="bg-white p-4 rounded-2xl shadow-sm border border-slate-100 flex items-center gap-4 relative overflow-hidden cursor-pointer hover:shadow-md transition-all active:scale-[0.98]"
        >
          {/* Status Indicator Bar */}
          <div className={`absolute left-0 top-0 bottom-0 w-1 ${getStatusColor(task.status)}`} />
          
          {/* Icon Box */}
          <div className={`w-10 h-10 rounded-full flex-shrink-0 flex items-center justify-center ${getStatusColor(task.status)} shadow-sm`}>
            {task.status === TaskStatus.IN_PROGRESS ? (
               <Loader2 size={18} className="text-white animate-spin" />
            ) : task.status === TaskStatus.COMPLETED ? (
               <CheckCircle2 size={18} className="text-white" />
            ) : (
               getServiceIcon(task.serviceType)
            )}
          </div>

          {/* Content */}
          <div className="flex-1 min-w-0">
            <div className="flex justify-between items-start">
              <h4 className="text-sm font-semibold text-slate-800 truncate">{task.title}</h4>
              <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-slate-100 text-slate-600 uppercase tracking-wide">
                {task.status === TaskStatus.IN_PROGRESS ? 'Running' : task.status}
              </span>
            </div>
            <p className="text-xs text-slate-500 truncate mt-0.5">{task.description}</p>
            
            <div className="flex items-center gap-3 mt-2">
               {task.eta && (
                 <div className="flex items-center gap-1 text-[10px] text-slate-500 font-medium bg-slate-50 px-1.5 py-0.5 rounded">
                   <Clock size={10} />
                   <span>{task.eta}</span>
                 </div>
               )}
               {task.price && (
                 <div className="text-[10px] text-slate-600 font-bold">
                   {task.price}
                 </div>
               )}
               <div className="flex-1 text-right text-[10px] text-primary font-medium tracking-tight">
                 via {task.mcpAgentName || 'MCP Core'}
               </div>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
};