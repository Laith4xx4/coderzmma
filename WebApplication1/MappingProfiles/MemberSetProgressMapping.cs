using AutoMapper;
using WebApplication1.Models;
using WebApplication1.DTOs;

namespace WebApplication1.MappingProfiles
{
    public class MemberProfileMapping : Profile
    {
        public MemberProfileMapping()
        {
            // Mapping MemberProfile -> DTO
            CreateMap<MemberProfile, MemberProfileResponseDto>()
                .ForMember(dest => dest.UserName, opt => opt.MapFrom(src => src.User.UserName))
                .ForMember(dest => dest.BookingsCount, opt => opt.MapFrom(src => src.Bookings.Count))
                .ForMember(dest => dest.AttendanceCount, opt => opt.MapFrom(src => src.Attendances.Count))
                .ForMember(dest => dest.FeedbacksGivenCount, opt => opt.MapFrom(src => src.FeedbacksGiven.Count))
                .ForMember(dest => dest.ProgressRecordsCount, opt => opt.MapFrom(src => src.ProgressRecords.Count));

            // Mapping DTOs -> MemberProfile
            CreateMap<CreateMemberProfileDto, MemberProfile>();
            CreateMap<UpdateMemberProfileDto, MemberProfile>();

            // ---------------- MemberSetProgress Mapping ----------------
            CreateMap<CreateMemberSetProgressDto, MemberSetProgress>();
            CreateMap<UpdateMemberSetProgressDto, MemberSetProgress>();
            CreateMap<MemberSetProgress, MemberSetProgressResponseDto>()
                .ForMember(dest => dest.MemberName, opt => opt.MapFrom(src => src.Member.User.UserName));
        }
    }
}
