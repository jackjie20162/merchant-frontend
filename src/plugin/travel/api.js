import { listTravelProducts, getTravelProduct, checkTravelInventory, createTravelOrder, getTravelOrder, createTravelPayment, getTravelPayment } from '../../api/travel'

export const travelProductList = listTravelProducts
export const travelProductDetail = getTravelProduct
export const travelInventoryCheck = checkTravelInventory
export const travelOrderCreate = createTravelOrder
export const travelOrderDetail = getTravelOrder
export const travelPaymentCreate = createTravelPayment
export const travelPaymentDetail = getTravelPayment
