import React, { useEffect, useState } from 'react';
import { Task, TaskStatus } from '../types';
import { X, CheckCircle2, Circle, Loader2, Clock, Check, AlertCircle } from 'lucide-react';

interface TaskDetailModalProps {
  task: Task | null;
  onClose: () => void;
}

export const TaskDetailModal: React.FC<TaskDetailModalProps> = ({ task, onClose }) => {
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    if (task) {
      setIsVisible(true);
    } else {
      setTimeout(() => setIsVisible(false), 300);
    }
  }, [task]);

  if (!task && !isVisible) return null;

  // Function to render the correct icon based on step status
  const getStepIcon = (status: TaskStatus) => {
    switch (status) {
      case TaskStatus.COMPLETED:
        return <Check size={14} className="text-white" />;
      case TaskStatus.IN_PROGRESS:
        return <Loader2 size={14} className="text-primary animate-spin" />;
      case TaskStatus.FAILED:
        return <AlertCircle size={14} className="text-white" />;
      default: // PENDING
        return <Circle size={14} className="text-slate-300" />;
    }
  };

  const getStepColor = (status: TaskStatus) => {
    switch (status) {
      case TaskStatus.COMPLETED:
        return 'bg-primary border-primary';
      case TaskStatus.IN_PROGRESS:
        return 'bg-white border-primary';
      case TaskStatus.FAILED:
        return 'bg-red-500 border-red-500';
      default: // PENDING
        return 'bg-slate-50 border-slate-300';
    }
  };

  return (
    <div 
      className={`fixed inset-0 z-50 flex items-end sm:items-center justify-center pointer-events-none ${task ? 'pointer-events-auto' : ''}`}
    >
      {/* Backdrop */}
      <div 
        className={`absolute inset-0 bg-black/40 backdrop-blur-sm transition-opacity duration-300 ${task ? 'opacity-100' : 'opacity-0'}`}
        onClick={onClose}
      />

      {/* Modal Content */}
      <div 
        className={`bg-white w-full max-w-md h-[85vh] sm:h-auto sm:max-h-[80vh] sm:rounded-3xl rounded-t-3xl shadow-2xl overflow-hidden flex flex-col relative transform transition-transform duration-300 ${
          task ? 'translate-y-0' : 'translate-y-full sm:translate-y-10 sm:scale-95'
        }`}
      >
        {/* Header */}
        <div className="px-6 py-5 border-b border-slate-100 flex justify-between items-center bg-white z-10">
          <div>
            <h3 className="font-bold text-lg text-slate-800">Task Details</h3>
            <p className="text-xs text-slate-500">ID: #{task?.id.slice(-6)}</p>
          </div>
          <button 
            onClick={onClose}
            className="p-2 bg-slate-100 hover:bg-slate-200 rounded-full transition-colors text-slate-600"
          >
            <X size={20} />
          </button>
        </div>

        {/* Scrollable Body */}
        <div className="flex-1 overflow-y-auto p-6 bg-slate-50/50">
          {task && (
            <div className="space-y-8">
              {/* Task Summary Card */}
              <div className="bg-white p-5 rounded-2xl shadow-sm border border-slate-100">
                <div className="flex justify-between items-start mb-4">
                  <div>
                    <h4 className="font-bold text-slate-800 text-lg mb-1">{task.title}</h4>
                    <p className="text-slate-500 text-sm">{task.description}</p>
                  </div>
                  <span className={`px-2.5 py-1 rounded-full text-xs font-bold uppercase tracking-wide ${
                    task.status === TaskStatus.COMPLETED ? 'bg-green-100 text-green-700' :
                    task.status === TaskStatus.IN_PROGRESS ? 'bg-blue-100 text-blue-700' :
                    task.status === TaskStatus.FAILED ? 'bg-red-100 text-red-700' :
                    'bg-yellow-100 text-yellow-700'
                  }`}>
                    {task.status === TaskStatus.IN_PROGRESS ? 'Running' : task.status}
                  </span>
                </div>
                
                <div className="grid grid-cols-2 gap-4 pt-4 border-t border-slate-100">
                  <div>
                    <p className="text-xs text-slate-400 font-medium uppercase tracking-wider mb-1">Estimated Cost</p>
                    <p className="font-bold text-slate-700">{task.price || '-'}</p>
                  </div>
                  <div className="text-right">
                    <p className="text-xs text-slate-400 font-medium uppercase tracking-wider mb-1">Agent</p>
                    <p className="font-bold text-primary">{task.mcpAgentName || 'System'}</p>
                  </div>
                </div>
              </div>

              {/* Execution Timeline */}
              <div>
                <h5 className="font-bold text-slate-800 mb-4 flex items-center gap-2">
                  <Loader2 size={16} className={`text-primary ${task.status === TaskStatus.IN_PROGRESS ? 'animate-spin' : ''}`} />
                  Execution Process
                </h5>
                
                <div className="relative pl-4 space-y-0">
                  {/* Vertical Line */}
                  <div className="absolute left-[27px] top-2 bottom-4 w-0.5 bg-slate-200 -z-10" />

                  {task.executionSteps?.map((step, index) => {
                    const isLast = index === (task.executionSteps.length - 1);
                    return (
                      <div key={step.id} className="relative flex gap-4 pb-8 last:pb-0 group">
                        {/* Dot */}
                        <div className={`w-6 h-6 rounded-full border-2 flex items-center justify-center flex-shrink-0 z-10 transition-colors duration-300 ${getStepColor(step.status)}`}>
                          {getStepIcon(step.status)}
                        </div>
                        
                        {/* Content */}
                        <div className={`flex-1 pt-0.5 transition-opacity duration-300 ${step.status === TaskStatus.PENDING ? 'opacity-50' : 'opacity-100'}`}>
                          <div className="flex justify-between items-start">
                             <h6 className="font-semibold text-slate-800 text-sm leading-tight">{step.label}</h6>
                             {step.timestamp && step.status !== TaskStatus.PENDING && (
                               <span className="text-[10px] text-slate-400 font-medium">
                                 {new Date(step.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                               </span>
                             )}
                          </div>
                          {step.details && (
                            <p className="text-xs text-slate-500 mt-1">{step.details}</p>
                          )}
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};