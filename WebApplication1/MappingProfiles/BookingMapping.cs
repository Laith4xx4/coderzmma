using AutoMapper;
using WebApplication1.Models;
using WebApplication1.DTOs;

namespace WebApplication1.MappingProfiles
{
    public class BookingMapping : Profile
    {
        public BookingMapping()
        {
            CreateMap<Booking, BookingResponseDto>()
                .ForMember(dest => dest.MemberName, opt => opt.MapFrom(src => src.Member.User.UserName ?? "غير محدد"))
                .ForMember(dest => dest.SessionName, opt => opt.MapFrom(src => src.Session != null ? src.Session.SessionName ?? "غير محدد" : "غير محدد"));

            CreateMap<CreateBookingDto, Booking>();
            CreateMap<UpdateBookingDto, Booking>();
        }
    }
}
