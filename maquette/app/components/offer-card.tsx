import { MapPin, Star } from 'lucide-react';
import { Offer } from '../data/mockData';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface OfferCardProps {
  offer: Offer;
  onUse?: (offerId: string) => void;
}

export function OfferCard({ offer, onUse }: OfferCardProps) {
  return (
    <div className="w-[240px] h-[280px] bg-white rounded-2xl overflow-hidden shadow-sm flex flex-col">
      {/* Image */}
      <div className="relative h-[120px] w-full">
        <ImageWithFallback
          src={offer.image}
          alt={offer.title}
          className="w-full h-full object-cover"
        />
        {/* Badge catégorie */}
        <div className="absolute top-2 left-2 bg-white/95 backdrop-blur-sm rounded-full px-3 py-1 flex items-center gap-1 shadow-sm">
          <span className="text-xs">{offer.categoryIcon}</span>
          <span className="text-[10px] font-semibold uppercase tracking-wide text-gray-800">
            {offer.category}
          </span>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 flex flex-col p-3">
        {/* Title */}
        <h3 className="font-semibold text-base leading-tight">{offer.title}</h3>
        
        {/* Subtitle */}
        <p className="text-sm text-red-600 mt-0.5">{offer.subtitle}</p>

        {/* Prix */}
        <div className="flex items-baseline gap-2 mt-2">
          <span className="text-xs text-gray-400 line-through">
            {offer.originalPrice.toLocaleString()} FCFA
          </span>
          <span className="text-base font-semibold text-green-600">
            {offer.finalPrice.toLocaleString()} FCFA
          </span>
        </div>

        {/* Info ligne */}
        <div className="flex items-center gap-3 mt-2 text-xs text-gray-500">
          <div className="flex items-center gap-1">
            <MapPin className="w-3 h-3" />
            <span>{offer.location}</span>
          </div>
          <div className="flex items-center gap-1">
            <Star className="w-3 h-3 fill-yellow-400 text-yellow-400" />
            <span>{offer.rating}</span>
          </div>
        </div>

        {/* Bouton */}
        <button
          onClick={() => onUse?.(offer.id)}
          className="w-full h-8 bg-red-600 hover:bg-red-700 text-white text-sm font-medium rounded-full mt-auto transition-colors"
        >
          Utiliser l'offre
        </button>
      </div>
    </div>
  );
}
