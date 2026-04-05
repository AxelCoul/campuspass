import { Outlet, useLocation } from 'react-router';
import { BottomNav } from './components/bottom-nav';

export function Layout() {
  const location = useLocation();
  
  // Hide bottom nav on merchant detail page
  const showBottomNav = !location.pathname.startsWith('/merchant/');

  return (
    <div className="w-full min-h-screen bg-gray-50">
      {/* Mobile container */}
      <div className="max-w-[390px] mx-auto bg-white shadow-xl min-h-screen relative">
        <Outlet />
        {showBottomNav && <BottomNav />}
      </div>
    </div>
  );
}
