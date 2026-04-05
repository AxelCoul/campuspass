import { Home, Compass, Heart } from 'lucide-react';
import { useNavigate, useLocation } from 'react-router';

export function BottomNav() {
  const navigate = useNavigate();
  const location = useLocation();

  const tabs = [
    { id: 'home', label: 'Home', icon: Home, path: '/' },
    { id: 'explorer', label: 'Explorer', icon: Compass, path: '/explorer' },
    { id: 'favoris', label: 'Favoris', icon: Heart, path: '/favoris' },
  ];

  return (
    <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 safe-area-bottom">
      <div className="flex items-center justify-around h-16 max-w-[390px] mx-auto">
        {tabs.map((tab) => {
          const Icon = tab.icon;
          const isActive = location.pathname === tab.path;
          
          return (
            <button
              key={tab.id}
              onClick={() => navigate(tab.path)}
              className="flex flex-col items-center justify-center gap-1 px-4 py-2 transition-colors"
            >
              <Icon 
                className={`w-6 h-6 ${isActive ? 'text-red-600' : 'text-gray-400'}`}
                fill={isActive ? 'currentColor' : 'none'}
              />
              <span className={`text-xs font-medium ${isActive ? 'text-red-600' : 'text-gray-500'}`}>
                {tab.label}
              </span>
            </button>
          );
        })}
      </div>
    </div>
  );
}
