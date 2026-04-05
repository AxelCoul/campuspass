import { MapPin, ChevronRight } from 'lucide-react';
import { Merchant } from '../data/mockData';
import { useNavigate } from 'react-router';

interface MerchantCardProps {
  merchant: Merchant;
}

export function MerchantCard({ merchant }: MerchantCardProps) {
  const navigate = useNavigate();

  return (
    <div
      onClick={() => navigate(`/merchant/${merchant.id}`)}
      className="w-full bg-white rounded-xl p-3 shadow-sm hover:shadow-md active:shadow-lg active:bg-gray-50/50 transition-all cursor-pointer"
    >
      <div className="flex items-center gap-3">
        {/* Logo */}
        <div className="w-12 h-12 flex-shrink-0 rounded-full bg-gray-100 flex items-center justify-center text-2xl">
          {merchant.logo}
        </div>

        {/* Info */}
        <div className="flex-1 min-w-0">
          {/* Nom */}
          <h3 className="font-semibold text-base leading-tight truncate">
            {merchant.name}
          </h3>
          
          {/* Catégorie */}
          <p className="text-xs text-gray-500 mt-0.5">
            {merchant.categoryIcon} {merchant.category} · {merchant.subcategory}
          </p>
          
          {/* Emplacement */}
          <div className="flex items-center gap-1 text-xs text-gray-500 mt-0.5">
            <MapPin className="w-3 h-3" />
            <span>{merchant.location} · {merchant.distance} km</span>
          </div>
        </div>

        {/* Droite */}
        <div className="flex items-center gap-2 flex-shrink-0">
          <div className="text-xs font-medium text-red-600">
            {merchant.offersCount} {merchant.offersCount > 1 ? 'offres' : 'offre'}
          </div>
          <ChevronRight className="w-4 h-4 text-gray-400" />
        </div>
      </div>
    </div>
  );
}
