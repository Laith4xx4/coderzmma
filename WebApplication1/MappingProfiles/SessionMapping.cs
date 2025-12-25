using AutoMapper;
using WebApplication1.Models;
using WebApplication1.DTOs;

namespace WebApplication1.MappingProfiles
{
    public class SessionMapping : Profile
    {
        public SessionMapping()
        {
            CreateMap<Session, SessionResponseDto>()
                .ForMember(dest => dest.CoachName, opt => opt.MapFrom(src => src.Coach.User.UserName))
                .ForMember(dest => dest.ClassTypeName, opt => opt.MapFrom(src => src.ClassType.Name))
                .ForMember(dest => dest.BookingsCount, opt => opt.MapFrom(src => src.Bookings.Count))
                .ForMember(dest => dest.AttendanceCount, opt => opt.MapFrom(src => src.Attendances.Count));

            CreateMap<CreateSessionDto, Session>();
            CreateMap<UpdateSessionDto, Session>();
        }
    }
}
